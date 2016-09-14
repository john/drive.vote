module Api::V1
  class RidesController < Api::ApplicationController
    include RideParams
    include AccessMethods

    before_action :find_ride
    before_action :require_ride_access

    def update_attribute
      if(params.has_key?(:name) && params.has_key?(:value))
        if @ride.update_attribute( params[:name], params[:value] )
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
