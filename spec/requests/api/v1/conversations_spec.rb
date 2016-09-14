require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  describe "GET /api/conversations" do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation_with_messages, ride_zone: rz}

    it "redirects if you're not logged in" do
      get api_v1_conversation_path(convo)
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      get api_v1_conversation_path(convo)
      expect(response).to have_http_status(200)
    end
  end
end
