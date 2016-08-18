class DispatchController < ApplicationController
  # before_action :ensure_dispatcher
  before_action :ensure_ride_zone, only: [:show]

  layout "fluid", only: [:show]

  # GET /dispatch
  def index
    @ride_zones = RideZone.all
  end

  # GET /dispatch/ride_zone
  def show
  end

  private

  def ensure_ride_zone
    @ride_zone = RideZone.find_by_id(params[:id])
    redirect_to root_path unless @ride_zone && current_user.has_role?(:dispatcher, @ride_zone)
  end
end
