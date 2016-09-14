require 'rails_helper'

RSpec.describe Api::V1::PlacesController, :type => :controller do
  describe 'search' do
    let(:result) { [{'name' => 'foo'}] }
    before :each do
      allow(GooglePlaces).to receive(:search).and_return(result)
    end

    it "redirects if not logged in" do
      get :search, params: {query: 'test'}
      expect(response).to redirect_to('/404.html')
    end

    context "logged in as a driver" do
      login_driver

      it 'is successful' do
        get :search, params: {query: 'test'}
        expect(response).to be_successful
      end

      it 'returns results' do
        get :search, params: {query: 'test'}
        expect(JSON.parse(response.body)['response']).to eq(result)
      end

      it 'returns error on error' do
        expect(GooglePlaces).to receive(:search).and_return(nil)
        get :search, params: {query: 'test'}
        expect(JSON.parse(response.body)['error']).to_not be_nil
      end
    end
  end
end
