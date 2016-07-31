require 'rails_helper'

RSpec.describe "RideZones", type: :request do
  describe "GET /admin/ride_zones" do
    it "works! (now write some real specs)" do
      get admin_ride_zones_path
      expect(response).to have_http_status(302)
    end
  end
end
