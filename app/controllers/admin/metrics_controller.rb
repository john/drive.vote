class Admin::MetricsController < Admin::AdminApplicationController

  # GET /admin/metrics
  def index
    if params[:rz_id].present?
      #@total_rides = ...scoped by rz
    else
      @voter_count = User.with_role(:voter, :any).count
      @ride_zone_count = RideZone.count
      @total_rides_count = Ride.count
      @completed_rides_count = Ride.where(status: :complete).count
      @conversation_count = Conversation.count
      @message_count = Message.count
    end
  end

end