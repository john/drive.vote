require 'rails_helper'

RSpec.describe "Users", :type => :request do
  describe "GET /admin/users" do
    it "works! (now write some real specs)" do
      get admin_users_path
      
      # redirecting because it's not authed
      expect(response).to have_http_status(302)
    end
  end
end
