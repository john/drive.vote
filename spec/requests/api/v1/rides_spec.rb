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
      expect(response).to have_http_status(200)
    end
  end
end
