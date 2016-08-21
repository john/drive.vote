class Ride < ApplicationRecord
  belongs_to :ride_zone

  enum status: { incomplete_info: 0, scheduled: 1, waiting_assignment: 2, driver_assigned: 3, picked_up: 4, complete: 5 }

  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  belongs_to :voter, class_name: 'User', foreign_key: :voter_id
  belongs_to :ride_zone
  has_one :conversation

  scope :completed, -> { where(status: :complete)}

  validates :voter, presence: true

  after_create :notify_creation
  before_save :note_status_update
  around_save :notify_update
  before_save :close_conversation_when_complete

  include HasAddress

  # create a new ride from the data in a conversation
  def self.create_from_conversation conversation
    attrs = {
      ride_zone: conversation.ride_zone,
      voter: conversation.user,
      name: conversation.username,
      pickup_at: conversation.pickup_time,
      status: :scheduled,
      from_address: conversation.from_address,
      from_city: conversation.from_city,
      from_latitude: conversation.from_latitude,
      from_longitude: conversation.from_longitude,
      to_address: conversation.to_address,
      to_city: conversation.to_city,
      to_latitude: conversation.to_latitude,
      to_longitude: conversation.to_longitude,
      additional_passengers: conversation.additional_passengers,
      special_requests: conversation.special_requests,
      conversation: conversation,
    }
    Ride.create!(attrs)
  end

  # returns true if assignment worked
  def assign_driver driver
    self.with_lock do # reloads record
      return false if self.driver_id
      self.driver = driver
      self.status = :driver_assigned
      save!
    end
    true
  end

  # returns true if driver was valid and cleared
  def clear_driver driver = nil
    return false if driver && self.driver_id != driver.id
    self.driver = nil
    self.status = :waiting_assignment
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
    j = self.as_json(except: [:created_at, :updated_at], methods: [:conversation_id])
    j['status_updated_at'] = self.status_updated_at.to_i
    j
  end

  def conversation_id
    self.conversation.try(:id)
  end

  def active?
    Ride.active_statuses.include?(self.status.to_sym)
  end

  # return up to limit Rides near the specified location
  def self.waiting_nearby ride_zone_id, latitude, longitude, limit, radius
    rides = Ride.where(ride_zone_id: ride_zone_id, status: :waiting_assignment).to_a
    pt = Geokit::LatLng.new(latitude, longitude)
    rides.map do |ride|
      ride_pt = Geokit::LatLng.new(ride.from_latitude, ride.from_longitude)
      dist = pt.distance_to(ride_pt)
      if dist < radius
        [dist, ride]
      else
        nil
      end
    end.compact.sort do |a, b|
      a[0] <=> b[0]
    end.map {|pair| pair[1]}[0..limit-1]
  end

  def self.active_statuses
    [:waiting_assignment, :driver_assigned, :picked_up]
  end

  def self.active_status_values
    self.active_statuses.map {|s| Ride.statuses[s]}
  end

  def passenger_count
    # always include Voter as a passenger
    self.additional_passengers + 1
  end

  private
  def notify_creation
    self.ride_zone.event(:new_ride, self) if self.ride_zone
  end

  def note_status_update
    self.status_updated_at = Time.now if new_record? || self.status_changed?
  end

  def notify_update
    was_new = new_record?
    # note, if we offer a one-step reassign, this only notifies on the old driver
    driver_to_notify = User.find_by_id(self.driver_id_was) || self.driver
    notify_driver = driver_to_notify && (driver_id_changed? || status_changed?)
    yield
    self.ride_zone.event(:ride_changed, self) if !was_new && self.ride_zone
    self.ride_zone.event(:driver_changed, driver_to_notify, :driver) if notify_driver && self.ride_zone
  end

  def close_conversation_when_complete
    self.conversation.update_attribute(:status, 'closed') if self.conversation && status_changed? && status == 'complete'
  end
end
