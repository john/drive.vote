module Api::V1
  class ConversationsController < Api::ApplicationController
    include ConversationParams

    before_action :find_conversation
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

    def create_message
      sms = TwilioService.send_message(
        { from: @conversation.to_phone, to: @conversation.from_phone, body: params[:message][:body]} ,
        TWILIO_TIMEOUT
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
