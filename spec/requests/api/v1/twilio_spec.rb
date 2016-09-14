require 'rails_helper'

RSpec.describe "Twilio", type: :request do
  describe "GET /api/1/twilio/sms" do
    let(:from_number) { '+12073328710' }
    let(:to_number) { '+14193860121' }
    let(:msg) { 'I need a ride' }

    it "succeeds if you're not logged in, since it's an external service" do
      post api_v1_twilio_sms_path, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      expect(response).to have_http_status(200)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      post api_v1_twilio_sms_path, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      expect(response).to have_http_status(200)
    end
  end
end
