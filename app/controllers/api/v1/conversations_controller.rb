module Api::V1
  class ConversationsController < Api::ApplicationController
    TWILIO_TIMEOUT = 5 # seconds

    before_action :find_conversation
    before_action :ensure_message, only: :create_message

    def show
      render json: {response: @conversation.api_json(true)}
    end

    def create_message
      sms = TwilioService.send_message(@conversation.to_phone, @conversation.from_phone, params[:message][:body], nil, TWILIO_TIMEOUT)
      if sms.error_code
        render json: {error: "Communication error #{sms.error_code}"}, status: 500
      elsif sms.status.to_s != 'delivered'
        render json: {error: 'Timeout in delivery'}, status: 503
      else
        Message.create_conversation_reply(@conversation, sms)
        render json: {response: 'ok'}, status: 200
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
