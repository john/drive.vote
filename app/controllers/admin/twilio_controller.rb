class Admin::TwilioController < Admin::AdminApplicationController
  include Webhookable

  before_action :establish_ride_zone
  before_action :establish_user_conversation
  skip_before_action :verify_authenticity_token
  skip_before_action :require_admin_priviledges

  CONFIG_ERROR_MSG = 'Sorry, we cannot process your request'.freeze

  rescue_from ConfigurationError do |e|
    # todo: alerting on errors
    logger.warn "Configuration error #{e.message} #{params}"
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
    message.save
    render_twiml_message(ConversationBot.new(@conversation, message).response)
  end

  # def voice
  #   response = Twilio::TwiML::Response.new do |r|
  #     r.Say 'Hey there. Congrats on integrating Twilio into your Rails 4 app.', :voice => 'alice'
  #        r.Play 'http://linode.rabasa.com/cantina.mp3'
  #   end
  #
  #   render_twiml response
  # end

  private

  # Find the ride zone based on the 'to' phone number
  def establish_ride_zone
    to_phone = PhonyRails.normalize_number(params[:to])
    @ride_zone = RideZone.find_by_phone_number(to_phone)
    raise ConfigurationError.new(CONFIG_ERROR_MSG) unless @ride_zone
  end

  # Find the user and any existing conversation, or create them as needed
  def establish_user_conversation
    from_phone = PhonyRails.normalize_number(params[:from])
    @user = User.find_by_phone_number_normalized(from_phone)
    if @user.nil?
      @user = User.create!(name: '', password: '12345678', phone_number: from_phone, phone_number_normalized: from_phone, uid: from_phone, provider: 'sms', email: "#{from_phone}@sms.org")
      # todo: user role as passenger?
    end
    @conversation = Conversation.where(user_id: @user.id).where.not(status: :closed).first
    @conversation ||= Conversation.create(user_id: @user.id, from_phone: from_phone, ride_zone: @ride_zone)
  end

  # def twilio_client
  #   account_sid = Rails.application.secrets.twilio_sid
  #   auth_token = Rails.application.secrets.twilio_token
  #   @twilio_client ||= Twilio::REST::Client.new account_sid, auth_token
  # end

end