class DispatchController < ApplicationController
  include RideZoneParams
  include AccessMethods

  before_action :set_ride_zone, except: [:messages, :ride_pane]
  before_action :require_zone_dispatch
  before_action :get_driver_count, except: [:messages, :ride_pane]

  def show
    @fluid = true
  end

  def messages
    @conversation = Conversation.find(params[:id])
    render partial: 'messages'
  end

  def ride_pane
    @conversation = Conversation.find(params[:id])
    ride = @conversation.ride
    @zone_driver_count = @conversation.ride_zone.drivers.count
    @available_drivers = @conversation.ride_zone.available_drivers
    @available_drivers_with_distance = @available_drivers.map  do |d|
      [d, ride ? ride.distance_to_point(d.latitude, d.longitude) : 0]
    end.sort do |pair1, pair2|
      pair1[1] <=> pair2[1]
    end

    if ride.present?
      @action =  'Edit'
      @obj = ride
    else # create ride
      @action =  'Create'
      @obj = @conversation
    end

    @pickup_at = @obj.try(:pickup_at).try(:in_time_zone, @obj.ride_zone.time_zone) || ""
    render partial: 'dispatch/form'
  end

  def drivers
    @sort = params[:sort]&.to_sym || :name
    @drivers = @ride_zone.drivers.order(@sort)
    if current_user.has_role?(:admin, @ride_zone) || current_user.has_role?(:admin)
      @unassigned_drivers = @ride_zone.unassigned_drivers.order(@sort )
      @nearby_drivers = @ride_zone.nearby_unassigned_drivers.order(@sort )
    end
    respond_to do |format|
      format.html
      format.csv do
        @all_drivers = @ride_zone.unassigned_drivers.merge( @ride_zone.drivers ).merge(@ride_zone.nearby_drivers)
        send_data @all_drivers.to_csv(headers: true), filename: "drivers-#{Date.today}.csv"
      end
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
