require 'rails_helper'

RSpec.describe Api::V1::RidesController, :type => :controller do

  let!(:ride) { create :ride, from_city: 'Toledo, OH' }

  it 'is successful' do
    post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
    expect(response).to be_successful
  end

  it 'updates a ride attribute' do
    expect(ride.from_city).to eq('Toledo, OH')
    post :update_attribute, params: {id: ride.id, name: 'from_city', value: 'Cleveland, OH'}
    expect(ride.reload.from_city).to eq('Cleveland, OH')
  end

  # spec that it's returning json

end
