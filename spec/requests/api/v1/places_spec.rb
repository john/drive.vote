require 'rails_helper'

RSpec.describe "Places", type: :request do
  describe "GET /api/places" do
    let(:result) { [{'name' => 'foo'}] }
    before :each do
      allow(GooglePlaces).to receive(:search).and_return(result)
    end

    it "redirects if not logged in" do
      get api_v1_places_search_path, params: {query: 'test'}
      expect(response).to have_http_status(302)
    end

    it "succeeds if you're logged in as an admin" do
      user = create(:admin_user)
      sign_in user

      get api_v1_places_search_path, params: {query: 'test'}
      expect(response).to have_http_status(200)
    end
  end
end
