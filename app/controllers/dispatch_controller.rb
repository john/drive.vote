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
    @zone_driver_count = User.with_role(:driver, @conversation.ride_zone).count
    @available_drivers = @conversation.ride_zone.available_drivers

    if @conversation.ride.present?
      # if params[:edit].blank?
      #   render partial: 'ride_info' # show ride info
      # else
        @action =  'Edit'
        @obj = @conversation.ride
        render partial: 'ride_form'
      # end

    elsif @conversation.ride.blank? # create ride
      @action =  'Create'
      @obj = @conversation
      render partial: 'ride_form'
    end
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
