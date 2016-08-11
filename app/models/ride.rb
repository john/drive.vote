class Ride < ApplicationRecord
  belongs_to :ride_zone

  enum status: { incomplete_info: 0, scheduled: 1, waiting_assignment: 2, driver_assigned: 3, picked_up: 4, complete: 5 }

  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  belongs_to :voter, class_name: 'User', foreign_key: :voter_id

  validates :voter, presence: true

  # returns true if assignment worked
  def assign_driver driver
    # avoid multiple simultaneous ride updates by enforcing null driver_id check
    assigned = Ride.statuses[:driver_assigned]
    safe_update = "update rides set driver_id = #{driver.id}, status = #{assigned} where id = #{self.id} and driver_id is null"
    (ActiveRecord::Base.connection.exec_update(safe_update) == 1)
  end

  # returns true if driver was valid and cleared
  def clear_driver driver
    return false unless self.driver_id == driver.id
    update_attributes(driver_id: nil, status: :waiting_assignment)
  end

  # returns true if driver owns this ride
  def pickup_by driver
    return false unless self.driver_id == driver.id
    update_attributes(status: :picked_up)
  end

  # returns true if driver owns this ride
  def complete_by driver
    return false unless self.driver_id == driver.id
    update_attributes(status: :complete)
  end

  # returns json suitable for exposing in the API
  def api_json
    self.as_json(except: [:created_at, :updated_at])
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

  def passenger_count
    # always include Voter as a passenger
    self.additional_passengers + 1
  end
end
