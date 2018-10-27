require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  describe "GET /admin/conversations" do

    it "redirects if you're not logged in" do
      get admin_conversations_path
      # expect(response).to have_http_status(404)
      expect(response).to have_http_status(302)
    end

    it "redirects if you're logged in as a non-admin" do
      user = create(:user)
      sign_in user

      get admin_conversations_path
      # expect(response).to have_http_status(404)
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      get admin_conversations_path
      expect(response).to be_successful
    end

  end
  