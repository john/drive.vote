require 'rails_helper'

RSpec.describe Api::V1::RideZonesController, :type => :controller do
  describe 'conversations' do
    let!(:notinrz) { create :conversation }
    let(:rz) { create :ride_zone }
    let!(:c1) { create :conversation, ride_zone: rz, status: :in_progress }
    let!(:c2) { create :conversation, ride_zone: rz, status: :ride_created }
    let!(:c3) { create :conversation, ride_zone: rz, status: :closed }

    it 'is successful' do
      get :conversations, params: {id: rz.id}
      response.should be_successful
    end

    it 'returns active conversations' do
      get :conversations, params: {id: rz.id}
      JSON.parse(response.body)['response'].should match_array([c1.api_json, c2.api_json])
    end

    it 'returns requested conversations' do
      get :conversations, params: {id: rz.id, status: :ride_created}
      JSON.parse(response.body)['response'].should match_array([c2.api_json])
    end

    it 'returns multitype requested conversations' do
      get :conversations, params: {id: rz.id, status: 'ride_created, closed'}
      JSON.parse(response.body)['response'].should match_array([c2.api_json, c3.api_json])
    end

    it '404s for missing ride zone' do
      get :conversations, params: {id: 0}
      response.status.should == 404
    end
  end

  describe 'drivers' do
    let!(:rz) { create :ride_zone }
    let!(:u1) { create :driver_user, ride_zone: rz }
    let!(:u2) { create :driver_user, ride_zone: rz }
    let(:rz2) { create :ride_zone }
    let!(:notinrz) { create :driver_user, ride_zone: rz2 }

    it 'is successful' do
      get :drivers, params: {id: rz.id}
      response.should be_successful
    end

    it 'returns drivers for ride zone' do
      get :drivers, params: {id: rz.id}
      resp = JSON.parse(response.body)['response']
      resp.should match_array([u1.api_json, u2.api_json])
    end

    it '404s for missing ride zone' do
      get :drivers, params: {id: 0}
      response.status.should == 404
    end
  end

  describe 'rides' do
    let!(:rz) { create :ride_zone }
    let!(:r_incomplete) { create :ride, ride_zone: rz }
    let!(:r_waiting) { create :waiting_ride, ride_zone: rz }
    let!(:r_assigned) { create :assigned_ride, ride_zone: rz }
    let!(:r_picked_up) { create :picked_up_ride, ride_zone: rz }
    let!(:r_complete) { create :complete_ride, ride_zone: rz }
    let(:rz2) { create :ride_zone }
    let!(:notinrz) { create :waiting_ride, ride_zone: rz2 }

    it 'is successful' do
      get :rides, params: {id: rz.id}
      response.should be_successful
    end

    it 'returns rides for ride zone' do
      get :rides, params: {id: rz.id}
      resp = JSON.parse(response.body)['response']
      resp.should match_array([r_waiting.api_json, r_assigned.api_json, r_picked_up.api_json])
    end

    it 'returns multitype requested conversations' do
      get :rides, params: {id: rz.id, status: 'driver_assigned, picked_up'}
      resp = JSON.parse(response.body)['response']
      resp.should match_array([r_assigned.api_json, r_picked_up.api_json])
    end

    it '404s for missing ride zone' do
      get :rides, params: {id: 0}
      response.status.should == 404
    end
  end

  describe 'create ride' do
    let!(:rz) { create :ride_zone }
    let!(:voter) { create :voter_user }

    it 'is successful' do
      post :create_ride, params: {id: rz.id, ride: { owner_id: voter.id, name: 'foo'} }
      response.should be_successful
    end

    it 'creates a new ride for the ride zone' do
      expect {
          post :create_ride, params: {id: rz.id, ride: { owner_id: voter.id, name: 'foo'} }
      }.to change(Ride, :count).by(1)
      Ride.first.name.should == 'foo'
    end

    it 'does not create a ride with missing owner_id' do
      expect {
          post :create_ride, params: {id: rz.id, ride: { name: 'foo' } }
      }.to change(Ride, :count).by(0)
      JSON.parse(response.body)['error'].should include('owner_id')
    end
  end
end
