require 'rails_helper'

RSpec.describe Api::V1::TwilioController, :type => :routing do
  describe 'routing' do

    it 'routes to create sms' do
      expect(post: '/api/1/twilio/sms').to route_to('api/v1/twilio#sms')
    end

  end
end
