module Webhookable
  extend ActiveSupport::Concern

  def set_twiml_headers
    response.headers['Content-Type'] = 'text/xml'
  end

  def render_twiml_message msg
    resp = Twilio::TwiML::Response.new do |r|
      r.Message msg
    end
    render_twiml(resp)
  end

  def render_twiml(twiml_response)
    set_twiml_headers
    render plain: twiml_response.text
  end
end