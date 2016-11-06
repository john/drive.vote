class TwilioService
  CONFIG_ERROR_MSG = 'Sorry, we cannot process your request'.freeze

  # processes an inbound Twilio message, creating user, conversation, and message
  # returns the text reply to send back
  def process_inbound_sms(params)
    establish_ride_zone(params)
    establish_user_conversation(params)
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

    message.save!
    return nil if @conversation.block_bot_reply?
    answer = ConversationBot.new(@conversation, message).response
    Message.create!(
        ride_zone: @ride_zone,
        conversation: @conversation,
        to: message.from,
        from: message.to,
        body: answer)
    answer
  end

  # sends an SMS message with specified data and waits up to timeout seconds
  # for the status to become 'delivered' or have a non-nil error_code
  # returns the Twilio message object unless there is a hard error from twilio
  # that raises
  def self.send_message(args, timeout)
    raise 'Do not call Twilio in test' if Rails.env.test?

    end_time = timeout.seconds.from_now
    sms = twilio_client.messages.create(args)
    while sms.error_code.nil? && sms.status.to_s != 'delivered' && Time.now <= end_time
        sleep(0.5)
        sms.refresh
    end
    sms
  end

  def self.get_message(sid)
    twilio_client.messages.get(sid)
  end

  private
  def self.twilio_client
    account_sid = Rails.application.secrets.twilio_sid
    auth_token = Rails.application.secrets.twilio_token
    Twilio::REST::Client.new account_sid, auth_token
  end

  private

  # Find the ride zone based on the 'to' phone number
  def establish_ride_zone(params)
    to_phone = PhonyRails.normalize_number(params['To'], default_country_code: 'US')
    @ride_zone = RideZone.find_by_phone_number_normalized(to_phone)
    raise ConfigurationError.new(CONFIG_ERROR_MSG) unless @ride_zone
  end

  # Find the user and any existing conversation, or create them as needed
  def establish_user_conversation(params)
    from_phone = PhonyRails.normalize_number(params['From'], default_country_code: 'US')
    sms_name = User.sms_name(from_phone)
    attrs = {
        name: sms_name,
        user_type: :voter,
        password: '12345678',
        phone_number: from_phone,
        phone_number_normalized: from_phone,
        email: User.autogenerate_email
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
