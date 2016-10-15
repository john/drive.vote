module Api::V1
  class RideZonesController < Api::ApplicationController
    include RideParams
    include RideZoneParams
    include AccessMethods

    before_action :require_ride_zone
    before_action :require_zone_access

    def conversations
      # default to non-closed statuses or passed parameter
      status_list = no_status? ? Conversation.active_statuses : status_array
      render json: {response: @ride_zone.conversations.where(status: status_list).map{|c| c.api_json(true)}}
    end

    # This creates an outbound conversation from the staff to either a driver or voter
    def create_conversation
      user = User.find_by_id(params[:user_id])
      if user
        resp = Conversation.create_from_staff(@ride_zone, user, params[:body], Rails.configuration.twilio_timeout)
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
      render json: {response: @ride_zone.nearby_drivers.map(&:api_json)}
    end

    def update
      if has_zone_dispatch?
        if (current_user.has_role?(:admin))
          @ride_zone.update(ride_zone_params)
        else
          # Restrict updates to only bot_disabled unless there are zone privileges.
          @ride_zone.bot_disabled = ride_zone_params['bot_disabled']
          @ride_zone.save!
        end
      end
      render json: @ride_zone
    end

    def assign_ride
      driver = User.find_by_id(params[:driver_id])
      ride = Ride.find_by_id(params[:ride_id])
      if driver && driver.active_ride
        render json: {error: 'Driver already has a ride', status: :conflict }
      elsif driver && ride
        ride.assign_driver(driver, true, true)
        render json: {response: driver.reload.api_json}
      else
        render json: {error: 'Driver or ride not found'}, status: :not_found
      end
    end

    def rides
      # default to active rides or those scheduled w/in 30 minutes
      scope = Ride.where(ride_zone: @ride_zone)
      if no_status?
        scope = scope.where('(status in (?) or (status = ? and pickup_at < ?))',
                            Ride.active_status_values, Ride.statuses[:scheduled], 30.minutes.from_now)
      else
        scope = scope.where(status: status_array)
      end
      render json: {response: scope.map(&:api_json)}
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
    def require_ride_zone
      set_ride_zone
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
