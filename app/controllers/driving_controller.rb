class DrivingController < ApplicationController

  before_action :ensure_session
  before_action :update_location_from_params
  before_action :update_active_ride

  skip_before_action :verify_authenticity_token

  RIDES_LIMIT = 10

  def index
    unless current_user && current_user.is_driver?
      sign_out
      redirect_to root_path and return
    else
      render :layout => false
    end
  end

  def demo
  end

  def update_location
    # work is done in before_action
    render json: {response: status_data}
  end

  def available
    current_user.update_attribute :available, true
    render json: {response: status_data}
  end

  def unavailable
    current_user.update_attribute :available, false
    render json: {response: status_data}
  end

  def status
    render json: {response: status_data}
  end

  def accept_ride
    if @active_ride && (@active_ride.id != params[:ride_id].to_i || @active_ride.status != 'waiting_acceptance')
      render json: {error: 'Driver already on ride'}, status: 400
    else
      update = -> { r = Ride.find(params[:ride_id]); r && r.assign_driver(current_user) }
      perform_update update, 'Ride was already taken by another driver'
    end
  end

  def unaccept_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      update = -> { r = Ride.find(params[:ride_id]); r && r.clear_driver(current_user) }
      perform_update update, 'Ride not for this driver'
    end
  end

  def pickup_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      update = -> { r = Ride.find(params[:ride_id]); r && r.pickup_by(current_user) }
      perform_update update, 'Ride not for this driver'
    end
  end

  def complete_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      update = -> { r = Ride.find(params[:ride_id]); r && r.complete_by(current_user) }
      perform_update update, 'Ride not for this driver'
    end
  end

  def cancel_ride
    if @active_ride.nil?
      render json: {error: 'Driver not on ride'}, status: 400
    else
      update = -> { r = Ride.find(params[:ride_id]); r && r.cancel(current_user.name) }
      perform_update update, 'Ride not for this driver'
    end
  end

  def waiting_rides
    rides = if @active_ride
              [ @active_ride ] # this allows for dispatcher assignment
            else
              rzid = current_user.driver_ride_zone_id
              Ride.waiting_nearby(rzid, current_user.latitude, current_user.longitude, RIDES_LIMIT, RideZone.find(rzid).nearby_radius)
            end
    render json: {response: rides.map {|r| r.api_json}, waiting_rides_interval: waiting_rides_interval}
  end

  def ridezone_stats
    stats = RideZone.find(current_user.driver_ride_zone_id).driving_stats
    render json: {response: stats}
  end

  private
  # if the client provided lat and long, update driver location
  def update_location_from_params
    lat, lng = params[:latitude], params[:longitude]
    return if lat.blank? || lng.blank?
    current_user.update_attributes(latitude: lat, longitude: lng)
  end

  def update_active_ride
    @active_ride.set_distance_to_voter(current_user.latitude, current_user.longitude) if @active_ride
  end

  # this routine executes function and renders OK response or error
  def perform_update func, error_msg
    if func.call
      @active_ride.try(:reload)
      render json: {response: status_data}
    else
      render json: {error: error_msg}, status: 400
    end
  end

  def ensure_session
    render :nothing => true, :status => 401 && return unless current_user
    @driver_id = current_user.id
    @active_ride = Ride.where(driver_id: @driver_id).where.not(status: Ride.complete_status_values).first
  end

  def update_location_interval
    Site.instance.update_location_interval
  end

  def waiting_rides_interval
    Site.instance.waiting_rides_interval
  end

  def status_data
    {
      available: current_user.available,
      active_ride: @active_ride.try(:api_json),
      ride_zone_id: current_user.driver_ride_zone_id,
      waiting_rides_interval: waiting_rides_interval,
      update_location_interval: update_location_interval
    }
  end
end
