class RideZone < ApplicationRecord
  resourcify

  has_many :conversations
  has_many :messages
  has_many :rides

  validates_presence_of :name

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
end
