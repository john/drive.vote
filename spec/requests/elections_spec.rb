require 'rails_helper'

RSpec.describe "Elections", type: :request do
  describe "GET /elections" do
    it "works! (now write some real specs)" do
      get elections_path
      expect(response).to have_http_status(200)
    end
  end
end
