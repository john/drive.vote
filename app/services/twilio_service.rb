class TwilioService

  # sends an SMS message with specified data and waits up to timeout seconds
  # for the status to become 'delivered' or have a non-nil error_code
  # returns the Twilio message object
  def self.send_message(args, timeout)
    sms = nil
    Timeout::timeout(timeout) do
      sms = twilio_client.messages.create(args)
      while sms.error_code.nil? && sms.status.to_s != 'delivered'
        sms.refresh
      end
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
end