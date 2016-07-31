require 'rails_helper'

RSpec.describe "Rides", type: :request do
  describe "GET /admin/rides" do
    it "works! (now write some real specs)" do
      get admin_rides_path
      expect(response).to have_http_status(302)
    end
  end
end
