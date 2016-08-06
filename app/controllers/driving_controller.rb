class DrivingController < ApplicationController

  before_action :ensure_session
  before_action :update_location_from_params

  OK_RESPONSE = {response: 'ok'}.freeze
  RIDES_LIMIT = 3
  RIDES_RADIUS = 10 # miles by default in Geokit
  UPDATE_LOCATION_INTERVAL = 60 # seconds
  WAITING_RIDES_INTERVAL = 15 # seconds

  def demo
  end

  def update_location
    # work is done in before_action
    render json: OK_RESPONSE.merge(update_location_interval: update_location_interval)
  end

  def available
    current_user.update_attribute :available, true
    render json: OK_RESPONSE
  end

  def unavailable
    current_user.update_attribute :available, false
    render json: OK_RESPONSE
  end

  def status
    data = {
      available: current_user.available,
      active_ride: @active_ride.try(:api_json),
      waiting_rides_interval: waiting_rides_interval,
      update_location_interval: update_location_interval
    }
    render json: {response: data}
  end

  def accept_ride
    if @active_ride
      render json: {error: 'Driver already on ride'}, status: 400
    else
      ride_id = params[:ride_id]
      assigned = Ride.statuses[:driver_assigned]
      # avoid multiple simultaneous ride updates by enforcing null driver_id check
      safe_update = "update rides set driver_id = #{@driver_id}, status = #{assigned} where id = #{ride_id} and driver_id is null"
      perform_update safe_update, 'Ride was already taken by another driver'
    end
  end

  def unaccept_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      ride_id = params[:ride_id]
      waiting = Ride.statuses[:waiting_pickup]
      safe_update = "update rides set driver_id = null, status = #{waiting} where id = #{ride_id} and driver_id = #{@driver_id}"
      perform_update safe_update, 'Ride was already taken'
    end
  end

  def pickup_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      ride_id = params[:ride_id]
      picked_up = Ride.statuses[:picked_up]
      # ensure driver is owner
      safe_update = "update rides set status = #{picked_up} where id = #{ride_id} and driver_id = #{@driver_id}"
      perform_update safe_update, 'Ride not for this driver'
    end
  end

  def complete_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      ride_id = params[:ride_id]
      complete = Ride.statuses[:complete]
      # ensure driver is owner
      safe_update = "update rides set status = #{complete} where id = #{ride_id} and driver_id = #{@driver_id}"
      perform_update safe_update, 'Ride not for this driver'
    end
  end

  def waiting_rides
    rides = if @active_ride
              [ @active_ride ] # this allows for dispatcher assignment
            else
              Ride.waiting_nearby(current_user.driver_ride_zone_id, current_user.latitude, current_user.longitude, RIDES_LIMIT, RIDES_RADIUS)
            end
    render json: {response: rides.map {|r| r.api_json}, waiting_rides_interval: waiting_rides_interval}
  end

  def ridezone_stats
    render json: {response: {}} # todo
  end

  private
  # if the client provided lat and long, update driver location
  def update_location_from_params
    lat, lng = params[:latitude], params[:longitude]
    return if lat.blank? || lng.blank?
    current_user.update_attributes(latitude: lat, longitude: lng)
  end

  # this routine executes a sql update and expects 1 row to be updated
  # in which case it will render an OK response
  # if zero rows were updated, it sends an error response with error_msg
  def perform_update sql, error_msg
    if ActiveRecord::Base.connection.exec_update(sql) == 1
      render json: OK_RESPONSE
    else
      render json: {error: error_msg}, status: 400
    end
  end

  def ensure_session
    render :nothing => true, :status => 301 unless current_user
    @driver_id = current_user.id
    @active_ride = Ride.where(driver_id: @driver_id).where.not(status: Ride.statuses[:complete]).first
  end

  def update_location_interval
    # todo: be able to throttle with this interval (redis?)
    UPDATE_LOCATION_INTERVAL
  end

  def waiting_rides_interval
    # todo: be able to throttle with this interval (redis?)
    WAITING_RIDES_INTERVAL
  end

end
