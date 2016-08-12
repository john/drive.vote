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
                                 :pickup_at,
                                 :name,
                                 :description,
                                 :special_requests,
                                 :status)
  end
end
