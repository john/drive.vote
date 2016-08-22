class DispatchController < ApplicationController
  # before_action :ensure_dispatcher
  before_action :set_ride_zone, only: [:show]
  before_action :require_zone_privilege, only: [:show]

  # GET /dispatch
  def index
    @ride_zones = RideZone.all
  end

  # GET /dispatch/ride_zone
  def show
    @fluid = true
  end

end
