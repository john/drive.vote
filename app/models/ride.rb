class Ride < ApplicationRecord
  belongs_to :ride_zone

  enum status: { incomplete_info: 0, scheduled: 1, waiting_pickup: 2, driver_assigned: 3, picked_up: 4, complete: 5 }

  validates_presence_of :owner_id
  belongs_to :driver, class_name: 'User', foreign_key: :driver_id

  # returns true if assignment worked
  def assign_driver driver
    # avoid multiple simultaneous ride updates by enforcing null driver_id check
    assigned = Ride.statuses[:driver_assigned]
    safe_update = "update rides set driver_id = #{driver.id}, status = #{assigned} where id = #{self.id} and driver_id is null"
    (ActiveRecord::Base.connection.exec_update(safe_update) == 1)
  end

  # returns true if driver was valid and cleared
  def clear_driver driver
    waiting = Ride.statuses[:waiting_pickup]
    safe_update = "update rides set driver_id = null, status = #{waiting} where id = #{self.id} and driver_id = #{driver.id}"
    (ActiveRecord::Base.connection.exec_update(safe_update) == 1)
  end

  # returns true if driver owns this ride
  def pickup_by driver
    picked_up = Ride.statuses[:picked_up]
    safe_update = "update rides set status = #{picked_up} where id = #{self.id} and driver_id = #{driver.id}"
    (ActiveRecord::Base.connection.exec_update(safe_update) == 1)
  end

  # returns true if driver owns this ride
  def complete_by driver
    complete = Ride.statuses[:complete]
    safe_update = "update rides set status = #{complete} where id = #{self.id} and driver_id = #{driver.id}"
    (ActiveRecord::Base.connection.exec_update(safe_update) == 1)
  end

  # returns json suitable for exposing in the API
  def api_json
    self.as_json(except: [:created_at, :updated_at, :driver_id, :owner_id, :ride_zone_id])
  end

  # return up to limit Rides near the specified location
  def self.waiting_nearby ride_zone_id, latitude, longitude, limit, radius
    rides = Ride.where(ride_zone_id: ride_zone_id, status: :waiting_pickup).to_a
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
    [:waiting_pickup, :driver_assigned, :picked_up]
  end
end
