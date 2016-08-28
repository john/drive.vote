require 'rails_helper'

RSpec.describe RidesController, type: :controller do

  describe 'GET #new' do
    it 'assigns a new ride as @ride' do
      rz = create(:ride_zone)
      get :new, params: {ride_zone_id: rz.id}
      expect(assigns(:ride)).to be_a_new(Ride)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested ride as @ride' do
      user = create :voter_user
      sign_in user
      ride = create :ride, voter: user, ride_zone: user.ride_zone
      get :edit, params: {id: ride.to_param}
      expect(assigns(:ride)).to eq(ride)
    end

    it 'redirects if not signed in' do
      user = create :voter_user
      ride = create :ride, voter: user, ride_zone: user.ride_zone
      get :edit, params: {id: ride.to_param}
      expect(response).to redirect_to('/users/sign_in')
    end
  end
end
