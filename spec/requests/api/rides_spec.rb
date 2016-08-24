require 'rails_helper'

RSpec.describe "Rides", type: :request do
  describe "GET /api/rides" do

    # for if and when we have some kind of auth
    # it "redirects if you're not logged in" do
    #   ride = create(:ride)
    #   post update_attribute_api_v1_ride_path(ride), params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
    #   expect(response).to have_http_status(302)
    # end

    it "succeeds" do
      # user = create(:user)
      # post user_session_path, params: {:login => user.email, :password => user.password }

      ride = create(:ride)
      post update_attribute_api_v1_ride_path(ride), params: {name: 'from_city', value: 'Cleveland, OH'}
      expect(response).to have_http_status(200)
    end

  end
end
