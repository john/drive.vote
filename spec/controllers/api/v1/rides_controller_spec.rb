require 'rails_helper'

RSpec.describe Api::V1::RidesController, :type => :controller do

  let!(:ride) { create :ride, from_city: 'Toledo, OH' }

  it "redirects if not logged in" do
    post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
    expect(response).to redirect_to('/404.html')
  end

  context "logged in as a driver" do
    login_driver

    it 'is successful' do
      post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(response).to be_successful
    end

    it 'updates a ride attribute' do
      expect(ride.from_city).to eq('Toledo, OH')
      post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(ride.reload.from_city).to eq('Cleveland, OH')
    end
  end

  context "logged in as a dispatcher" do
    login_dispatcher

    it 'is successful' do
      post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(response).to be_successful
    end

    it 'updates a ride attribute' do
      expect(ride.from_city).to eq('Toledo, OH')
      post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(ride.reload.from_city).to eq('Cleveland, OH')
    end
  end

end
