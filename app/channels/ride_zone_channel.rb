class RideZoneChannel < ApplicationCable::Channel
  # called when a new dispatch connection is established
  def subscribed
    logger.debug "RideZone connection from #{current_user.name} to #{params[:id]}"

    # Set up a stream specific to this ride zone
    stream_from "ride_zone_#{params[:id]}"
  end
end
