require 'rails_helper'

RSpec.describe "Elections", type: :request do
  describe "GET /admin/elections" do
    it "works! (now write some real specs)" do
      get admin_elections_path
      expect(response).to have_http_status(302)
    end
  end
end
