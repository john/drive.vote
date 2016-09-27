class DispatchController < ApplicationController
  include RideZoneParams
  include AccessMethods

  before_action :set_ride_zone
  before_action :require_zone_dispatch
  before_action :get_driver_count

  # GET /dispatch/:ride_zone
  def show
    @fluid = true
  end

  def drivers
    @drivers = @ride_zone.drivers.order(:name)
    if current_user.has_role?(:admin, @ride_zone)
      @unassigned_drivers = @ride_zone.unassigned_drivers.order(:name)
    end
  end

  def flyer
    respond_to do |format|
      format.pdf do
        pdf = RideZonePdf.new(@ride_zone, view_context)
        send_data pdf.render, filename:
        "ride_zone_#{@ride_zone.slug}.pdf",
        disposition: "inline",
        type: "application/pdf"
      end
    end
  end

  def map
  end

  private

  def get_driver_count
    @driver_count = @ride_zone.drivers.count(:all)
  end

end
