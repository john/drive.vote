require 'rails_helper'

RSpec.describe "TopLevel", type: :request do
  describe "GET /" do
    it "serves index page" do
      get root_path
      expect(response).to have_http_status(200)
    end

    it "serves the generic volunteer page" do
      get "/volunteer_to_drive"
      expect(response).to have_http_status(200)
    end

    it "serves ride zone sign up page" do
      ride_zone = create(:ride_zone)

      get "/volunteer_to_drive/#{ride_zone.id}"
      expect(response).to have_http_status(200)
    end

    it "serves confirm page" do
      get confirm_path
      expect(response).to have_http_status(200)
    end

    it "serves about page" do
      get about_path
      expect(response).to have_http_status(200)
    end

    it "serves code_of_conduct page" do
      get code_of_conduct_path
      expect(response).to have_http_status(200)
    end

    it "serves terms_of_service page" do
      get terms_of_service_path
      expect(response).to have_http_status(200)
    end

    it "serves privacy page" do
      get privacy_path
      expect(response).to have_http_status(200)
    end
  end
end
