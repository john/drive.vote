require 'rails_helper'

RSpec.describe HomeController, :type => :controller do

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET about" do
    it "returns http success" do
      get :about
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET privacy" do
    it "returns http success" do
      get :privacy
      expect(response).to have_http_status(:success)
    end
  end

end
