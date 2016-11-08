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

        if params[:name] == 'pickup_at'
          val = TimeZoneUtils.origin_time(params[:value], @conversation.ride_zone.time_zone)
        else
          val = params[:value]
        end
        new_status = %w(sms_created in_progress).include?(@conversation.status) ? 'help_needed' : @conversation.status
        if @conversation.update_attributes( params[:name] => val, status: new_status )
          render json: {response: @conversation.reload.api_json(false)}
        else
          render json: {error: @conversation.errors}
        end
      else
        render json: {error: 'missing params'}
      end
    end

    def remove_help_needed
      if @conversation.ride && @conversation.lifecycle == 'info_complete'
        @conversation.update_attributes(status: :ride_created)
        render json: {response: @conversation.reload.api_json(false)}
      else
        render json: {error: 'Conversation must have ride and be info complete'}, status: 400
      end
    end

    def create_message
      msg = @conversation.send_from_staff(params[:message][:body], Rails.configuration.twilio_timeout)
      if msg.is_a?(String)
        render json: {error: msg}, status: 500
      else
        render json: {response: {message: {sent_at: I18n.localize(msg.created_at, format: '%-m/%-d  %l:%M%P'), body: "#{msg.body}" }}}, status: 200
      end
    end

    def create_ride
      # if driver_id is present, make sure they can be added before doing anything
      driver = nil
      if params[:driver_id].present?
        if (driver = User.find_by_id(params[:driver_id])).nil?
          render json: {error: "Could not find driver"}, status: 500
          return
        end
      end

      ActiveRecord::Base.transaction do
        if ride = Ride.create_from_conversation(@conversation)
          ride.assign_driver( driver, true, true ) if driver
          @conversation.mark_info_completed(ride)
          @conversation.user.mark_info_completed
          render json: {response: ride.reload.api_json}
        else
          render json: {error: "Could not create Ride from Conversation"}, status: 500
        end
      end
    end

    # POST /admin/conversations/1/close
    def close
      @conversation.close(current_user.name)
      render json: {response: @conversation.reload.api_json}
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
