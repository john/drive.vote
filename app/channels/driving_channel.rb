class DrivingChannel < ApplicationCable::Channel
  # called when a new driver connection is established
  def subscribed
    logger.debug "DrivingChannel connection from #{current_user.name}"
    # Set up a stream specific to this driver
    stream_from "driving_channel_#{current_user.id}"
    # Set up a ridezone-specific stream, e.g. for stats about the ride zone (total # rides, active drivers, etc)
    stream_from "ridezone_channel_#{current_user.ride_zone_id}"

    # DEMO ONLY - just to show how we would broadcast "ride available" to the driver or other bits of info
    Thread.new do
      while true do
        ActionCable.server.broadcast "driving_channel_#{current_user.id}", { type: 'ride_available', data: {time: Time.now.iso8601, latitude: 1, longitude: 2} }
        sleep(5)
        ActionCable.server.broadcast "ridezone_channel_#{current_user.ride_zone_id}", { type: 'stats', data: {time: Time.now.iso8601, drivers: 3} }
        sleep(5)
      end
    end
  end

  # driver app is giving us new location
  def location_update data
    current_user.update_attributes({latitude: data['latitude'], longitude: data['longitude']})
  end

  # driver app telling us it is available
  def available
    current_user.update_attribute :available, true
    # todo: this should trigger some task to find the driver a nearby rider
  end

  # driver app telling us it is available
  def unavailable
    current_user.update_attribute :available, false
  end
end
