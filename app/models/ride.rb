class Ride < ApplicationRecord
  include HasAddress
  include ToFromAddressable

  SWITCH_TO_WAITING_ASSIGNMENT = 15 # how long in minutes before pickup time to change status to waiting_assignment

  enum status: {
    incomplete_info: 0,
    scheduled: 1,
    waiting_assignment: 2,
    driver_assigned: 3,
    picked_up: 4,
    complete: 5,
    waiting_acceptance: 6,
    canceled: 7,
  }

  belongs_to :ride_zone
  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  belongs_to :voter, class_name: 'User', foreign_key: :voter_id
  belongs_to :ride_zone
  has_one :conversation

  scope :completed, -> { where(status: Ride.complete_statuses)}

  validates :voter, presence: true
  validates :name, length: { maximum: 50 }
  validates :from_address, length: { maximum: 100 }
  validates :from_city, length: { maximum: 50 }
  validates :from_state, length: { maximum: 2 }
  validates :from_zip, length: { maximum: 15 }
  validates :to_address, length: { maximum: 100 }
  validates :to_city, length: { maximum: 50 }
  validates :to_state, length: { maximum: 2 }
  validates :to_zip, length: { maximum: 15 }
  validates :phone_number, length: { maximum: 17 }
  validates :email, length: { maximum: 50 }
  validate :geocoded_and_in_radius

  before_save :note_status_update
  before_save :check_waiting_assignment
  before_save :notify_voter_about_driver
  around_save :notify_update
  before_save :close_conversation_when_complete

  # for ride + voter creation
  attr_accessor :phone_number
  attr_accessor :email
  attr_accessor :from_city_state
  attr_accessor :to_city_state

  # transient for returning distance to voter
  attr_accessor :distance_to_voter

  # create a new ride from the data in a conversation
  def self.create_from_conversation conversation
    attrs = {
      ride_zone: conversation.ride_zone,
      voter: conversation.user,
      name: conversation.username,
      pickup_at: conversation.pickup_at,
      status: :scheduled,
      from_address: conversation.from_address,
      from_city: conversation.from_city,
      from_latitude: conversation.from_latitude,
      from_longitude: conversation.from_longitude,
      to_address: conversation.to_address,
      to_city: conversation.to_city,
      to_latitude: conversation.to_latitude,
      to_longitude: conversation.to_longitude,
      additional_passengers: conversation.additional_passengers || 0,
      special_requests: conversation.special_requests || '',
      conversation: conversation,
    }
    ActiveRecord::Base.transaction do
      conversation.update_attribute(:status, :ride_created)
      Ride.create!(attrs)
    end
  end

  # return true if ride can be assigned
  def assignable?
    %w(scheduled waiting_assignment ).include?(self.status)
  end

  # returns true if assignment worked
  def assign_driver driver, allow_reassign = false, needs_acceptance = false
    self.with_lock do # reloads record
      return false if !allow_reassign && self.driver_id && self.driver_id != driver.id
      self.driver = driver
      self.status = needs_acceptance ? :waiting_acceptance : :driver_assigned
      save!
    end
    true
  end

  # returns true if assignment worked
  def reassign_driver driver
    assign_driver(driver, true)
  end

  # returns true if driver was valid and cleared
  def clear_driver driver = nil
    return false if driver && self.driver_id != driver.id
    self.driver = nil
    self.status = :waiting_assignment unless self.status == 'canceled'
    save!
  end

  # returns true if driver owns this ride
  def pickup_by driver
    return false unless self.driver_id == driver.id
    self.status = :picked_up
    save!
  end

  # returns true if driver owns this ride
  def complete_by driver
    return false unless self.driver_id == driver.id
    self.status = :complete
    save!
  end

  # returns json suitable for exposing in the API
  def api_json
    j = self.as_json(except: [:voter_id, :driver_id, :pickup_at, :created_at, :updated_at], methods: [:conversation_id])
    j['driver_name'] = CGI::escape_html(driver_name || '')
    j['pickup_at'] = self.pickup_at.try(:to_i)
    j['created_at'] = self.created_at.try(:to_i)
    j['status_updated_at'] = self.status_updated_at.to_i
    j['voter_phone_number'] = self.voter.phone_number_normalized
    j['distance_to_voter'] = self.distance_to_voter.round(2) if self.distance_to_voter
    j
  end

  def conversation_id
    self.conversation.try(:id)
  end

  def driver_name
    self.driver.try(:name)
  end

  def active?
    Ride.active_statuses.include?(self.status.to_sym)
  end

  def pickup_in_time_zone
    if self.ride_zone
      self.pickup_at.in_time_zone(self.ride_zone.time_zone)
    else
      self.pickup_at
    end
  end

  def set_distance_to_voter(latitude, longitude)
    pt = Geokit::LatLng.new(latitude, longitude)
    ride_pt = Geokit::LatLng.new(self.from_latitude, self.from_longitude)
    self.distance_to_voter = pt.distance_to(ride_pt)
  end

  def distance_to_point(latitude, longitude)
    pt = Geokit::LatLng.new(latitude, longitude)
    ride_pt = Geokit::LatLng.new(self.from_latitude, self.from_longitude)
    pt.distance_to(ride_pt)
  end

  # return up to limit Rides near the specified location
  def self.waiting_nearby ride_zone_id, latitude, longitude, limit, radius
    rides = Ride.where(ride_zone_id: ride_zone_id, status: :waiting_assignment).to_a
    pt = Geokit::LatLng.new(latitude, longitude)
    rides.map do |ride|
      ride_pt = Geokit::LatLng.new(ride.from_latitude, ride.from_longitude)
      dist = pt.distance_to(ride_pt)
      if dist < radius
        ride.distance_to_voter = dist
        [dist, ride]
      else
        nil
      end
    end.compact.sort do |a, b|
      a[0] <=> b[0]
    end.map {|pair| pair[1]}[0..limit-1]
  end

  def self.active_statuses
    [:waiting_acceptance, :waiting_assignment, :driver_assigned, :picked_up]
  end

  def self.active_status_values
    self.active_statuses.map {|s| Ride.statuses[s]}
  end

  def self.complete_statuses
    [:complete, :canceled]
  end

  def self.complete_status_values
    self.complete_statuses.map {|s| Ride.statuses[s]}
  end

  def self.confirm_scheduled_rides
    results = Hash.new(0)
    Ride.where(status: :scheduled).where('pickup_at < ?', SWITCH_TO_WAITING_ASSIGNMENT.minutes.from_now).each do |ride|
      
      # disabling the bot previously disabled confirmation, but I think we need those regardless...
      if ride.conversation && ride.ride_zone
        
        # If we have an email it was probably a scheduled ride, use it to send a notification.
        if ride.voter.present? && ride.voter.email.present?
          UserMailer.notify_scheduled_ride(ride).deliver_now
        end
        
        begin
          result = ride.conversation.attempt_confirmation
          results[result] += 1
        rescue => e
          logger.error "Got error trying to confirm conversation #{ride.conversation.id}: #{e.message}"
          results['exception'] += 1
        end
      end
    end
    logger.warn "Note: Attempted to confirm #{results.count} scheduled rides (#{results})"
  end

  def passenger_count
    # always include Voter as a passenger
    self.additional_passengers + 1
  end

  def status_str
    self.status ? self.status.gsub('_', ' ').titleize : 'N/A'
  end

  def cancel(username)
    timestamp = self.ride_zone.current_time.strftime('%m/%d %l:%M%P %Z')
    self.status = :canceled
    self.description = (self.description || '') + " canceled by #{username} at #{timestamp}"
    save!
    clear_driver if self.driver
  end

  private
  def check_waiting_assignment
    if self.status == 'scheduled' && self.pickup_at && self.pickup_at < SWITCH_TO_WAITING_ASSIGNMENT.minutes.from_now
      self.status = :waiting_assignment
    end
  end

  def notify_voter_about_driver
    return if self.conversation.nil? || self.status == 'canceled'
    # notify voter IF
    # ride became driver_assigned or is assigned and driver id changed or driver was cleared when it was assigned
    if ((self.status_changed? || self.driver_id_changed?) && self.status == 'driver_assigned') ||
       (self.driver_id_changed? && self.driver.nil? && self.status_was == 'driver_assigned')
      self.conversation.notify_voter_of_assignment(self.driver)
    end
  end

  def note_status_update
    self.status_updated_at = Time.now if new_record? || self.status_changed?
  end

  def notify_update
    was_new = self.new_record?
    old_driver = User.find_by_id(self.driver_id_was)
    new_driver = self.driver
    notify_old_driver = old_driver != new_driver
    yield
    rz_id = self.ride_zone_id || self.ride_zone.try(:id)
    if rz_id
      RideZone.event(rz_id, :conversation_changed, self.conversation) if !was_new && self.conversation
      RideZone.event(rz_id, :driver_changed, old_driver, :driver) if notify_old_driver && old_driver
      RideZone.event(rz_id, :driver_changed, new_driver, :driver) if new_driver
    end
  end

  def close_conversation_when_complete
    if self.conversation && status_changed? && (status == 'complete' || status == 'canceled')
      self.conversation.update_attributes(status: 'closed')
    end
  end

  def geocoded_and_in_radius
    unless from_address.blank?
      if from_latitude.nil? || from_longitude.nil?
        errors.add(:from_address, 'could not be found')
      elsif ride_zone && !ride_zone.is_within_pickup_radius?(from_latitude, from_longitude)
        errors.add(:from_address, 'is outside the coverage area')
      end
    end
  end
end
