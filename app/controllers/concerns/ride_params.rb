module RideParams
  extend ActiveSupport::Concern

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ride
    @ride = Ride.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ride_params
    params.require(:ride).permit(:voter_id,
                                 :driver_id,
                                 :ride_zone_id,
                                 :additional_passengers,
                                 :city_state, # used by google places api, gets parsed into city/state fields
                                 :from_address,
                                 :from_city,
                                 :from_state,
                                 :from_zip,
                                 :to_city,
                                 :to_state,
                                 :to_zip,
                                 :pickup_at,
                                 :name,
                                 :phone_number, # this is a pass-thru to user
                                 :email, # this is a pass-thru to user
                                 :description,
                                 :special_requests,
                                 :status)
  end

  protected

  def find_ride
    @ride = Ride.find_by_id(params[:id])
    render json: {error: 'Ride not found'}, status: 404 unless @ride
  end

end
