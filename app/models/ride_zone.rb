class RideZone < ApplicationRecord
  resourcify

  has_many :conversations
  has_many :messages
  has_many :rides

  validates_presence_of :name
  validates_presence_of :zip

  # TODO: Specs need to be mocked before this is enabled
  # geocoded_by :zip
  # after_create :geocode

  def drivers
    User.with_role(:driver, self)
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
