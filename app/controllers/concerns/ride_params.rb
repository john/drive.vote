module RideParams
  extend ActiveSupport::Concern

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ride
    @ride = Ride.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ride_params
    params.require(:ride).permit(:owner_id, :name, :description, :status)
  end
end
