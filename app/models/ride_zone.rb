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

  validates :name, length: { maximum: 50 }
  validates :phone_number, length: { maximum: 20 }
  validates :slug, length: { maximum: 20 }
  validates :description, length: { maximum: 200 }
  validates :city, length: { maximum: 50 }
  validates :state, length: { maximum: 2 }
  validates :zip, length: { maximum: 12 }
  validates :nearby_radius, numericality: true, inclusion: { in: 1..100, message: 'must be between 1 and 100 miles' }

  geocoded_by :zip
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state_code
      obj.country = geo.country_code
    end
  end

  after_validation :geocode, if: ->(obj){ obj.zip.present? && obj.zip_changed? && !obj.latitude_changed? }
  after_validation :set_time_zone, if: ->(obj){ obj.latitude.present? && obj.latitude_changed? }
  after_validation :reverse_geocode, if: ->(obj){ (obj.latitude.present? && obj.latitude_changed?) || (obj.longitude.present? && obj.longitude_changed?) }

  # for creating an admin at the same time the rz is created
  attr_accessor :admin_name
  attr_accessor :admin_email
  attr_accessor :admin_phone_number
  attr_accessor :admin_password

  def self.with_user_in_role(user, role)
    role_ids = Role.where(resource_type: 'RideZone', name: role).where.not(resource_id: nil).pluck(:id)
    return RideZone.none if role_ids.empty?
    users_roles = UsersRoles.where(user_id: user.id, role_id: role_ids).distinct(:role_id).pluck(:role_id)
    zone_ids = Role.where(id: users_roles).pluck(:resource_id)
    RideZone.where(id: zone_ids)
  end

  def nearby_users
    User.nearby_ride_zone self
  end

  def active_rides
    # convoluted because you have to get the enum integer. probably a more graceful way to do it.
    self.rides.where("status IN (?)", Ride.active_statuses.map { |stat| Ride.statuses[stat] })
  end

  def admins
    named_role(:admin)&.users || User.none
  end

  def dispatchers
    named_role(:dispatcher)&.users || User.none
  end

  def drivers
    named_role(:driver)&.users || User.none
  end

  def on_duty_drivers
    self.drivers.where(available: true)
  end

  def nearby_drivers
    return User.none unless role = named_role(:driver)
    zone_driver_ids = role.users.pluck(:id)
    nearby_users.where(id: zone_driver_ids)
  end

  def unassigned_drivers
    named_role(:unassigned_driver)&.users || User.none
  end

  def nearby_unassigned_drivers
    role = Role.where(name: :unassigned_driver, resource_id: nil).first
    return User.none unless role
    unassigned_driver_ids = role.users.pluck(:id)
    nearby_users.where(id: unassigned_driver_ids)
  end

  def unavailable_drivers
    self.active_rides.map {|ar| ar.driver}
  end

  def available_drivers(all: false)
    if all
      drivers - unavailable_drivers
    else
      nearby_drivers - unavailable_drivers
    end
  end

  def driving_stats
    # todo: cache this (redis? memcache?) to avoid excessive db queries
    {
      total_drivers: drivers.count,
      available_drivers: drivers.where(available: true).count,
      completed_rides: Ride.where(ride_zone_id: self.id, status: :complete).count,
      active_rides: Ride.where(ride_zone_id: self.id, status: Ride.active_statuses).count,
      scheduled_rides: Ride.where(ride_zone_id: self.id, status: :scheduled).count,
    }
  end

  def current_time
    Time.use_zone(self.time_zone) do Time.current; end
  end

  def is_within_pickup_radius?(latitude, longitude)
    return true unless self.latitude && self.longitude
    pt = Geokit::LatLng.new(latitude, longitude)
    rz_center = Geokit::LatLng.new(self.latitude, self.longitude)
    pt.distance_to(rz_center) <= self.max_pickup_radius
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

  private
  def named_role(name)
    Role.where(resource_type: 'RideZone', resource_id: self.id, name: name).first
  end
end
