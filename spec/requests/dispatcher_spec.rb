require 'rails_helper'

RSpec.describe "Dispatcher", type: :request do
  describe "GET /dispatcher" do

    context "not logged in" do
      let(:ride_zone) { create :ride_zone }

      it "redirects the dispatch page" do
        get dispatch_path(ride_zone)
        expect(response).to have_http_status(302)
      end

      it "redirects the drivers page" do
        get drivers_dispatch_path(ride_zone)
        expect(response).to have_http_status(302)
      end

      it "doesn't let you download drivers.csv" do
        get drivers_dispatch_path(ride_zone, format: 'csv')
        expect(response).to have_http_status(302)
      end

      it "redirects map page" do
        get map_dispatch_path(ride_zone)
        expect(response).to have_http_status(302)
      end
    end

    context "logged in as regular user" do
      let(:ride_zone) { create :ride_zone }
      let(:user) { create :user }

      before :each do
        sign_in user
      end

      it "redirects dispatch page" do
        get dispatch_path(ride_zone)
        expect(response).to have_http_status(302)
      end

      it "redirects drivers page" do
        get drivers_dispatch_path(ride_zone)
        expect(response).to have_http_status(302)
      end

      it "doesn't let you download drivers" do
        get drivers_dispatch_path(ride_zone, format: 'csv')
        expect(response).to have_http_status(302)
      end

      it "redirects map page" do
        get map_dispatch_path(ride_zone)
        expect(response).to have_http_status(302)
      end

    end

    context "logged in as a dispatcher" do
      let(:ride_zone) { create :ride_zone }
      let(:user) { create :user }

      before :each do
        user.add_role(:dispatcher, ride_zone)
        sign_in user
      end

      it "lets you view the dispatch page" do
        get dispatch_path(ride_zone)
        expect(response).to be_successful
      end

      it "lets you view map page" do
        get map_dispatch_path(ride_zone)
        expect(response).to be_successful
      end

      it "lets you view drivers page" do
        get drivers_dispatch_path(ride_zone)
        expect(response).to be_successful
      end

      it "doesn't let you download drivers" do
        get drivers_dispatch_path(ride_zone, format: 'csv')
        expect(response).to have_http_status(302)
      end
    end

    context "logged in as a zone admin" do
      let(:ride_zone) { create :ride_zone }
      let(:user) { create :user }

      before :each do
        user.add_role(:admin, ride_zone)
        sign_in user
      end

      it "lets you download drivers.csv if you're a zone admin" do
        get drivers_dispatch_path(ride_zone, format: 'csv')
        expect(response).to be_successful
      end

      it "csv downloads with the correct Content-Type header" do
        get drivers_dispatch_path(ride_zone, format: 'csv')
        expect(response.headers["Content-Type"]).to eq "text/csv"
      end

      it "csv downloads with the correct Content-Type header" do
        get drivers_dispatch_path(ride_zone, format: 'csv')
        expect(response.headers["Content-Disposition"]).to include("attachment; filename=")
      end
    end
  end
end
