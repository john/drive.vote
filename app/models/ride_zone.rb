class RideZone < ApplicationRecord
  resourcify

  has_many :conversations
  has_many :messages
  has_many :rides

  validates_presence_of :name
  validates_presence_of :zip

  geocoded_by :zip
  after_validation :geocode, if: ->(obj){ obj.zip.present? && obj.zip_changed? }


  def active_rides
    # convoluted because you have to get the enum integer. probably a more graceful way to do it.
    self.rides.where("status IN (?)", Ride.active_statuses.map { |stat| Ride.statuses[stat] })
  end

  def drivers
    User.with_role(:driver, self)
  end

  def unavailable_drivers
    self.active_rides.map {|ar| ar.driver}
  end

  def available_drivers
    User.with_role(:driver, self) - unavailable_drivers
  end

  def dispatchers
    User.with_role(:dispatcher, self)
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

  # call this to broadcast an event for this ride zone
  # the object must respond to :api_json
  def event(event_type, object, tag = nil)
    event = {
      event_type: event_type,
      timestamp: Time.now.to_i,
      tag || object.class.name.downcase => object.send(:api_json)
    }
    ActionCable.server.broadcast "ride_zone_#{self.id}", event
  end
end
