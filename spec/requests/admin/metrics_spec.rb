require 'rails_helper'

RSpec.describe "Metrics", type: :request do
  describe "GET /admin/metrics" do

    it "redirects if you're not logged in" do
      get admin_metrics_path
      expect(response).to have_http_status(302)
    end

    it "redirects if you're logged in as a non-admin" do
      user = create(:user)
      sign_in user

      get admin_metrics_path
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      # user.add_role(:admin)
      sign_in user

      get admin_metrics_path
      expect(response).to be_successful
    end

  end
end
