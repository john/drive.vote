module Api::V1
  class TwilioController < Api::ApplicationController
    include Webhookable

    before_action :establish_ride_zone
    before_action :establish_user_conversation
    skip_before_action :verify_authenticity_token

    CONFIG_ERROR_MSG = 'Sorry, we cannot process your request'.freeze

    rescue_from ConfigurationError do |e|
      # todo: alerting on errors
      logger.warn "Configuration error #{e.message} #{params.inspect}"
      render_twiml_message(e.message)
    end

    # accept an inbound SMS from twilio and format a response to it
    def sms
      message = Message.new
      message.ride_zone = @ride_zone
      message.conversation = @conversation
      params.each do |param|
        message.public_send( "#{param.underscore}=", params[param] ) if message.respond_to? param.underscore
      end

      if @conversation.messages.empty?
        @conversation.to_phone = params['To']
        @conversation.from_phone = params['From']
        @conversation.save!
      end

      message.save
      return if @conversation.status == 'help_needed' || @conversation.staff_initiated?
      answer = ConversationBot.new(@conversation, message).response
      answer_msg = Message.create(
          ride_zone: @ride_zone,
          conversation: @conversation,
          to: message.from,
          from: message.to,
          body: answer)
      render_twiml_message(answer)
    end

    private

    # Find the ride zone based on the 'to' phone number
    def establish_ride_zone
      to_phone = PhonyRails.normalize_number(params['To'])
      @ride_zone = RideZone.find_by_phone_number(to_phone)
      raise ConfigurationError.new(CONFIG_ERROR_MSG) unless @ride_zone
    end

    # Find the user and any existing conversation, or create them as needed
    def establish_user_conversation
      to_phone = PhonyRails.normalize_number(params['To'])
      from_phone = PhonyRails.normalize_number(params['From'])
      sms_name = User.sms_name(from_phone)
      attrs = {
          name: sms_name,
          user_type: :voter,
          password: '12345678',
          phone_number: from_phone,
          phone_number_normalized: from_phone,
          email: "#{Time.now.to_f}@example.com"
      }
      # create the user and rescue duplicate record error to find existing one
      @user = begin
        User.create!(attrs)
      rescue ActiveRecord::RecordNotUnique
        User.where(phone_number_normalized: from_phone).first
      end
      @conversation = Conversation.where(user_id: @user.id).where.not(status: :closed).first
      @conversation ||= Conversation.create(status: :sms_created, user_id: @user.id, ride_zone: @ride_zone)
    end

  end
end
