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
      ride = create(:ride)
      get :edit, params: {id: ride.to_param}
      expect(assigns(:ride)).to eq(ride)
    end
  end
end
