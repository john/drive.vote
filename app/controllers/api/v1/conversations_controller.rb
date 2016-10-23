module Api::V1
  class ConversationsController < Api::ApplicationController
    include ConversationParams
    include AccessMethods

    before_action :find_conversation
    before_action :require_conversation_access
    before_action :ensure_message, only: :create_message

    def show
      render json: {response: @conversation.api_json(true)}
    end

    def update
      # caller is passing name as part of conversation hash but we need
      # to make it safe for updating the user object
      user_params = params.require(:conversation).permit(:name)
      unless user_params[:name].blank?
        @conversation.user.update_attribute(:name, user_params[:name])
      end
      if @conversation.update(conversation_params)
        render json: {response: @conversation.reload.api_json(false)}
      else
        render json: {error: @conversation.errors}
      end
    end

    def update_attribute
      if(params.has_key?(:name) && params.has_key?(:value))

        # this is a conversation, so we need to change the field name to pickup_time
        if params[:name] == 'pickup_at'
          name = 'pickup_time'
          val = TimeZoneUtils.origin_time(params[:value], @conversation.ride_zone.time_zone)
        else
          name = params[:name]
          val = params[:value]
        end

        if @conversation.update_attributes( name.to_sym => val )
          @conversation.validate
          render json: {response: @conversation.reload.api_json(false)}
        else
          render json: {error: @conversation.errors}
        end
      else
        render json: {error: 'missing params'}
      end
    end

    def create_message
      sms = TwilioService.send_message(
        { from: @conversation.to_phone, to: @conversation.from_phone, body: params[:message][:body]} ,
        Rails.configuration.twilio_timeout
      )
      if sms.error_code
        render json: {error: "Communication error #{sms.error_code}"}, status: 500
      elsif sms.status.to_s != 'delivered'
        render json: {error: 'Timeout in delivery'}, status: 503
      else
        msg = Message.create_conversation_reply(@conversation, sms)
        render json: {response: {message: {sent_at: I18n.localize(msg.created_at, format: '%-m/%-d  %l:%M%P'), body: "#{msg.body}" }}}, status: 200
      end
    end

    def create_ride
      # if driver_id is present, make sure they can be added before doing anything
      if params[:driver_id].present?
        if driver = User.find( params[:driver_id] )
          if ride = Ride.create_from_conversation( @conversation )
            ride.assign_driver( driver, true, true )
            render json: {response: ride.reload.api_json}
          else
            render json: {error: "Could not create Ride from Conversation"}, status: 500
          end
        else
          render json: {error: "Could not find driver"}, status: 500
        end
      else

        # if no driver_id, go ahead and create the ride
        if ride = Ride.create_from_conversation( @conversation )
          render json: {response: ride.reload.api_json}
        else
          render json: {error: "Could not create Ride from Conversation"}, status: 500
        end

      end

    end

    private
    def find_conversation
      @conversation = Conversation.find_by_id(params[:id])
      render json: {error: 'Conversation not found'}, status: 404 unless @conversation
    end

    def ensure_message
      render json: {error: 'Missing message parameter'}, status: 400 if params[:message].try(:[], :body).blank?
    end
  end
end
