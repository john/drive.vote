class Admin::MetricsController < Admin::AdminApplicationController

  # GET /admin/metrics
  def index
    if @ride_zone
      @title = @ride_zone.name
      @voter_count = @ride_zone.voters.count
      @ride_zone_count = 1
      @total_rides_count = Ride.where(ride_zone_id: @ride_zone.id).count
      @completed_rides_count = Ride.where(ride_zone_id: @ride_zone.id, status: :complete).count
      @conversation_count = Conversation.where(ride_zone_id: @ride_zone.id).count
      @message_count = Message.where(ride_zone_id: @ride_zone.id).count
    else
      @title = 'Drive the Vote'
      @voter_count = User.with_role(:voter, :any).count
      @driver_count = User.with_role(:driver, :any).count
      @ride_zone_count = RideZone.count
      @total_rides_count = Ride.count
      @completed_rides_count = Ride.where(status: :complete).count
      @canceled_rides_count = Ride.where(status: :canceled).count
      @conversation_count = Conversation.count
      @message_count = Message.count
    end
  end

end