module Api::V1
  class RidesController < Api::ApplicationController
    include RideParams
    include AccessMethods

    before_action :find_ride
    before_action :require_ride_access

    def update_attribute
      if(params.has_key?(:name) && params.has_key?(:value))

        if params[:name] == 'pickup_at'
          Time.use_zone(@ride.ride_zone.time_zone) do
            Time.zone.strptime(params[:value], "%m/%d/%Y, %I:%M%p")
          end
          val = origin_time
        else
          val = params[:value]
        end

        if @ride.update_attribute( params[:name], val )
          render json: {response: @ride.reload.api_json}
        else
          render json: {error: @ride.errors}
        end

      else
        render json: {error: 'missing params'}
      end
    end

  end
end
