require 'rails_helper'

RSpec.describe "Dispatcher", type: :request do
  describe "GET /dispatcher" do

    it "redirects dispatch page if you're not logged in" do
      ride_zone = create(:ride_zone)
      get dispatch_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "redirects dispatch page if you're logged in but not a dispatcher" do
      user = create(:user)
      sign_in user

      ride_zone = create(:ride_zone)
      get dispatch_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "lets you view dispatch page if you're a dispatcher for it" do
      ride_zone = create(:ride_zone)
      user = create(:user)
      user.add_role(:dispatcher, ride_zone)

      sign_in user

      get dispatch_path(ride_zone)
      expect(response).to have_http_status(200)
    end

    it "redirects drivers page if you're not logged in" do
      ride_zone = create(:ride_zone)
      get drivers_dispatch_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "redirects drivers page if you're logged in but not a dispatcher" do
      user = create(:user)
      sign_in user

      ride_zone = create(:ride_zone)
      get drivers_dispatch_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "lets you view drivers page page if you're a dispatcher for it" do
      ride_zone = create(:ride_zone)
      user = create(:user)
      user.add_role(:dispatcher, ride_zone)

      sign_in user

      get drivers_dispatch_path(ride_zone)
      expect(response).to have_http_status(200)
    end

    it "redirects map page if you're not logged in" do
      ride_zone = create(:ride_zone)
      get map_dispatch_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "redirects map page if you're logged in but not a dispatcher" do
      user = create(:user)
      sign_in user

      ride_zone = create(:ride_zone)
      get map_dispatch_path(ride_zone)
      expect(response).to have_http_status(302)
    end

    it "lets you view map page page if you're a dispatcher for it" do
      ride_zone = create(:ride_zone)
      user = create(:user)
      user.add_role(:dispatcher, ride_zone)

      sign_in user

      get map_dispatch_path(ride_zone)
      expect(response).to have_http_status(200)
    end
  end
end
