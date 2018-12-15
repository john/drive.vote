require 'rails_helper'

RSpec.describe "RideUploads", type: :request do
  describe "GET /ride_uploads" do
    
    context "not logged in" do
      let(:ride_zone) { create :ride_zone }

      it "works! (now write some real specs)" do
        get admin_ride_zone_ride_uploads_path(1)
        expect(response).to have_http_status(302)
      end
    end
    
    context "logged in as admin" do
      let(:ride_zone) { create :ride_zone }
      let(:user) { create :admin_user }

      before :each do
        sign_in user
      end

      it "works! (now write some real specs)" do
        get admin_ride_zone_ride_uploads_path(ride_zone.to_param)
        expect(response).to have_http_status(200)
      end
    end
  
  end
end
