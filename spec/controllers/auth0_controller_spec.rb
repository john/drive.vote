require 'rails_helper'

RSpec.describe Auth0Controller, type: :controller do

  describe "GET #callback" do
    it "returns http success" do
      skip
      get :callback
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #failure" do
    it "returns http success" do
      skip
      get :failure
      expect(response).to have_http_status(:success)
    end
  end

end
