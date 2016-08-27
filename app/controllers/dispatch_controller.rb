class DispatchController < ApplicationController
  before_action :set_ride_zone, only: [:show, :drivers, :map]
  before_action :require_zone_privilege, only: [:show, :drivers, :map]

  # GET /dispatch/ride_zone
  def show
    @fluid = true
  end

  def drivers
  end

  def map
  end

end
