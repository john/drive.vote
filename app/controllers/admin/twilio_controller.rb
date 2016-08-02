class Admin::TwilioController < Admin::AdminApplicationController
  include Webhookable

  after_filter :set_header
  skip_before_action :verify_authenticity_token
  
  skip_before_action :require_admin_priviledges
  
  def sms
    message = Message.new
    params.each do |param|
      message.public_send( "#{param.underscore}=", params[param] ) if message.respond_to? param.underscore
    end
    
    message.save
    
    # ActionCable.server.broadcast 'messages', { from: message.from, body: message.body, status: message.status }
    # ActionCable.server.broadcast 'message', { from: message.from, body: message.body, status: message.status }
    # head :ok
    
    if ride_zone = RideZone.find_by_phone_number( message.to )
      message.ride_zone_id = ride_zone.id
      
      if message.save
        message.reload
        message_body = params["Body"]
        from_number = params["From"]
        
        logger.debug '--------------'
        logger.debug "from_number: #{from_number}"
        logger.debug "rideaarea number: #{ride_zone.phone_number}"
        logger.debug '--------------'
        
        boot_twilio
        sms = @client.messages.create(
          message_id: message.id,
          to: from_number,
          from: ride_zone.phone_number,
          body: "Hi, thanks for contacting us. Someone will text you momentarily to arrange a ride."
        )
      else
        logger.debug "FAIL! Was not able to save message."
      end
      
    end 
    
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
 
  def boot_twilio
    account_sid = Rails.application.secrets.twilio_sid
    logger.debug "account_sid: '#{account_sid}'"
    
    auth_token = Rails.application.secrets.twilio_token
    logger.debug "auth_token: '#{auth_token}'"
    
    @client = Twilio::REST::Client.new account_sid, auth_token
  end
  
end