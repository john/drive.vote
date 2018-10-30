require 'rails_helper'

RSpec.describe "Rides", type: :request do
  describe "GET /api/1/rides/:id" do
    let(:ride) { create :ride }

    it "redirects if you're not logged in" do
      post update_attribute_api_v1_ride_path(ride), params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      post update_attribute_api_v1_ride_path(ride), params: {name: 'from_city', value: 'Cleveland, OH'}
      expect(response).to be_successful
    end
  end
  
  describe "GET /api/1/rides/confirm_scheduled" do
    let(:ride) { create :ride }

    it "404s with no auth key" do
      post confirm_scheduled_api_v1_rides_path
      expect(response).to have_http_status(404)
    end

    it "succeeds with X-Token header" do
      allow(ENV).to receive(:[]).with("PING_API_SECRET").and_return("1234abcd")

      post confirm_scheduled_api_v1_rides_path, headers: { 'X-Token' => "1234abcd" }
      expect(response).to be_successful
    end
  end
end
