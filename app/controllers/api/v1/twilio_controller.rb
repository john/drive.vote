module Api::V1
  class TwilioController < Api::ApplicationController
    include Webhookable

    skip_before_action :verify_authenticity_token # coming from the outside, can't do csrf

    rescue_from ConfigurationError do |e|
      # TODO: alerting on errors
      logger.warn "Configuration error #{e.message} #{params.inspect}"
      render_twiml_message(e.message)
    end

    # accept an inbound SMS from twilio and format a response to it
    def sms
      reply = TwilioService.new.process_inbound_sms(params)
      render_twiml_message(reply) if reply
    end

    def voice
      resp = Twilio::TwiML::Response.new do |r|
        r.Say "Thanks for calling drive the vote. This number does not accept voice calls. Please text 'human' to this number and someone will respond."
      end
      render_twiml(resp)
    end
  end
end
