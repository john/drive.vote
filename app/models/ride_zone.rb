class RideZone < ApplicationRecord
  resourcify

  has_many :conversations
  has_many :messages
  has_many :rides

  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'

  validates :phone_number_normalized, phony_plausible: true
  validates_presence_of :name
  validates_presence_of :zip
  validates_presence_of :slug
  validates_uniqueness_of :slug

  geocoded_by :zip
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state_code
      obj.country = geo.country_code
    end
  end

  after_validation :geocode, if: ->(obj){ obj.zip.present? && obj.zip_changed? }
  after_validation :set_time_zone, if: ->(obj){ obj.latitude.present? && obj.latitude_changed? }
  after_validation :reverse_geocode, if: ->(obj){ (obj.latitude.present? && obj.latitude_changed?) || (obj.longitude.present? && obj.longitude_changed?) }

  # for creating an admin at the same time the rz is created
  attr_accessor :admin_name
  attr_accessor :admin_email
  attr_accessor :admin_phone_number
  attr_accessor :admin_password

  def nearby_users
    User.nearby_ride_zone self
  end

  def active_rides
    # convoluted because you have to get the enum integer. probably a more graceful way to do it.
    self.rides.where("status IN (?)", Ride.active_statuses.map { |stat| Ride.statuses[stat] })
  end

  def admins
    User.with_role(:admin, self)
  end

  def dispatchers
    User.with_role(:dispatcher, self)
  end

  def drivers
    nearby_users.with_role(:driver, self)
  end

  def unassigned_drivers
    nearby_users.with_role(:unassigned_driver, self)
  end

  def unavailable_drivers
    self.active_rides.map {|ar| ar.driver}
  end

  def available_drivers
    nearby_users.with_role(:driver, self) - unavailable_drivers
  end

  def driving_stats
    # todo: cache this (redis? memcache?) to avoid excessive db queries
    {
      total_drivers: User.with_role(:driver, self).count,
      available_drivers: User.with_role(:driver, self).where(available: true).count,
      completed_rides: Ride.where(ride_zone_id: self.id, status: :complete).count,
      active_rides: Ride.where(ride_zone_id: self.id, status: Ride.active_statuses).count,
      scheduled_rides: Ride.where(ride_zone_id: self.id, status: :scheduled).count,
    }
  end

  def current_time
    Time.use_zone(self.time_zone) do Time.current; end
  end

  # call this to broadcast an event for this ride zone
  # the object must respond to :api_json
  def self.event(rz_id, event_type, object, tag = nil)
    event = {
      event_type: event_type,
      timestamp: Time.now.to_i,
      tag || object.class.name.downcase => object.send(:api_json)
    }
    ActionCable.server.broadcast "ride_zone_#{rz_id}", event
  end

  def set_time_zone
    return unless self.latitude && self.longitude
    tz = Timezone.lookup(self.latitude, self.longitude) rescue nil
    self.time_zone = tz.name unless tz.nil?
  end
end
