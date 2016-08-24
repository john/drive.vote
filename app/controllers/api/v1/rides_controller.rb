module Api::V1
  class RidesController < Api::ApplicationController
    include RideParams

    before_action :find_ride

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

    private

    def find_ride
      @ride = Ride.find_by_id(params[:id])
      render json: {error: 'Ride not found'}, status: 404 unless @ride
    end

  end
end
