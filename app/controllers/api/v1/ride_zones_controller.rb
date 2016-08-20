module Api::V1
  class RideZonesController < Api::ApplicationController
    include RideParams

    before_action :find_ride_zone

    def conversations
      # default to non-closed statuses or passed parameter
      status_list = no_status? ? Conversation.active_statuses : status_array
      render json: {response: @ride_zone.conversations.where(status: status_list).map{|c| c.api_json(true)}}
    end

    # This creates an outbound conversation from the staff to either a driver or voter
    def create_conversation
      user = User.find_by_id(params[:user_id])
      if user
        resp = Conversation.create_from_staff(@ride_zone, user, params[:body], TWILIO_TIMEOUT)
        if resp.is_a?(Conversation)
          render json: {response: resp.api_json}
        else
          render json: {error: resp}, status: :request_timeout # just call twilio errors timeouts
        end
      else
        render json: {error: 'User not found'}, status: :not_found
      end
    end

    def drivers
      render json: {response: @ride_zone.drivers.map(&:api_json)}
    end

    def rides
      # default to active rides
      status_list = no_status? ? Ride.active_statuses : status_array
      render json: {response: @ride_zone.rides.where(status: status_list).map(&:api_json)}
    end

    def create_ride
      @ride = Ride.new(ride_params.merge(ride_zone_id: @ride_zone.id))

      if @ride.save
        @ride.conversation = Conversation.find(params[:conversation_id]) if params[:conversation_id]
        render json: {response: @ride.api_json}
      else
        render json: {error: @ride.errors.messages.map {|k,v| "#{k} - #{v.join(',')}"}.join(' and ')}, status: 400
      end
    end

    private
    def find_ride_zone
      @ride_zone = RideZone.find_by_id(params[:id])
      render json: {error: 'RideZone not found'}, status: :not_found unless @ride_zone
    end

    def no_status?
      params[:status].to_s.strip.blank?
    end

    def status_array
      params[:status].to_s.split(',').map(&:strip)
    end
  end
end
