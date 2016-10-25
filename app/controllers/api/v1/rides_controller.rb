module Api::V1
  class RidesController < Api::ApplicationController
    include RideParams
    include AccessMethods

    before_action :find_ride, except: [:confirm_scheduled]
    before_action :require_ride_access, except: [:confirm_scheduled]
    skip_before_action :verify_authenticity_token, only: [:confirm_scheduled]

    def update_attribute
      if(params.has_key?(:name) && params.has_key?(:value))

        if params[:name] == 'pickup_at'
          val = TimeZoneUtils.origin_time(params[:value], @ride.ride_zone.time_zone)
        else
          val = params[:value]
        end

        if @ride.update_attributes( params[:name] => val )
          render json: {response: @ride.reload.api_json}
        else
          render json: {error: @ride.errors}
        end

      else
        render json: {error: 'missing params'}
      end
    end

    def confirm_scheduled
      Ride.confirm_scheduled_rides
      render text: 'ok'
    end
  end
end
