require 'rails_helper'

RSpec.describe "RideZones", type: :request do
  describe "GET /api/1/ride_zones/:id/conversations" do
    let(:rz) { create :ride_zone }
    let!(:c1) { create :conversation, ride_zone: rz, status: :in_progress }

    it "redirects if you're not logged in" do
      get conversations_api_v1_ride_zone_path(rz)
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      get conversations_api_v1_ride_zone_path(rz)
      expect(response).to be_successful
    end
  end
end
