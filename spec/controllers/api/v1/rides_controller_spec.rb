require 'rails_helper'

RSpec.describe Api::V1::RidesController, :type => :controller do
  let(:rz) { create :ride_zone }
  let!(:ride) { create :ride, to_city: 'Toledo, OH', ride_zone: rz, conversation: (create :complete_conversation) }
  let(:dispatcher) { create :dispatcher_user }

  it "redirects if not logged in" do
    post :update_attribute, params: {id: ride.id, name: 'to_city', value: 'Cleveland, OH'}
    expect(response).to redirect_to('/404.html')
  end

  context "logged in as a driver" do
    login_driver

    it 'is successful' do
      post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(response).to be_successful
    end

    it 'updates a ride attribute' do
      expect(ride.to_city).to eq('Toledo, OH')
      post :update_attribute, params: {id: ride.id, name: 'to_city', value: 'Cleveland, OH'}
      expect(ride.reload.to_city).to eq('Cleveland, OH')
    end
    
    it 'updates a conversation attribute via the ride' do
      expect(ride.conversation.from_city).to eq('fake_city')
      post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
      expect(ride.reload.from_city).to eq('Cleveland, OH')
    end
  end

  context "logged in as an admin" do
    login_admin

    it 'is successful' do
      post :update_attribute, params: {id: ride.id, name: 'to_city', value: 'Akron, OH'}
      expect(response).to be_successful
    end

    it 'updates a ride attribute' do
      expect(ride.to_city).to eq('Toledo, OH')
      post :update_attribute, params: {id: ride.id, name: 'to_city', value: 'Akron, OH'}
      expect(ride.reload.to_city).to eq('Akron, OH')
    end
  end

end
