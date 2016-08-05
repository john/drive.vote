require 'rails_helper'

RSpec.describe "RideZones", type: :request do
  describe "GET /admin/ride_zones" do

    it "redirects if you're not logged in" do
      get admin_ride_zones_path
      expect(response).to have_http_status(302)
    end

    it "redirects if you're logged in as a non-admin" do
      user = create(:user)
      post user_session_path, params: { :login => user.email, :password => user.password }

      get admin_ride_zones_path
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      post user_session_path, params: { 'user[email]' => user.email, 'user[password]' => user.password }
      follow_redirect!

      get admin_ride_zones_path
      expect(response).to have_http_status(200)
    end

  end
end
