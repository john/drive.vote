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
  end
end
