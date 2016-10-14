require 'rails_helper'

RSpec.describe DrivingController, :type => :controller do
  let(:rz) { create :ride_zone }
  let(:driver) { create :driver_user, ride_zone: rz }
  let(:car_location) { {latitude: 35, longitude: -122} }

  before :each do
    allow(controller).to receive(:signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(driver)
  end

  def verify_location_updated
    expect(driver.reload.latitude).to eq(car_location[:latitude])
    expect(driver.longitude).to eq(car_location[:longitude])
  end

  describe 'update location' do
    it 'is successful' do
      post :update_location, params: car_location
      expect(response).to be_successful
    end

    it 'updates driver location' do
      post :update_location, params: car_location
      verify_location_updated
    end

    it 'returns calculated interval' do
      allow(controller).to receive(:update_location_interval).and_return(42)
      post :update_location, params: car_location
      expect(JSON.parse(response.body)['response']['update_location_interval']).to eq(42)
    end
  end

  describe 'set available' do
    before :each do
      driver.update_attribute :available, false
    end

    it 'is successful' do
      post :available, params: car_location
      expect(response).to be_successful
    end

    it 'updates availability' do
      post :available, params: car_location
      expect(driver.reload.available).to eq(true)
    end

    it 'updates driver location' do
      post :available, params: car_location
      verify_location_updated
    end
  end

  describe 'set unavailable' do
    before :each do
      driver.update_attribute :available, true
    end

    it 'is successful' do
      post :unavailable, params: car_location
      expect(response).to be_successful
    end

    it 'updates availability' do
      post :unavailable, params: car_location
      expect(driver.reload.available).to eq(false)
    end
  end

  describe 'get status' do
    let(:expected) { {'available' => true, 'active_ride' => nil, 'waiting_rides_interval' => 24, 'update_location_interval' => 42} }
    before :each do
      driver.update_attributes(available: true, latitude: 34, longitude: -122)
      allow(controller).to receive(:update_location_interval).and_return(expected['update_location_interval'])
      allow(controller).to receive(:waiting_rides_interval).and_return(expected['waiting_rides_interval'])
    end

    it 'is successful' do
      get :status
      expect(response).to be_successful
    end

    it 'returns data when no ride' do
      get :status
      expect(JSON.parse(response.body)['response']).to eq(expected)
    end

    it 'returns data with ride' do
      ride = create :ride, status: :picked_up, driver: driver, from_latitude: 34.1, from_longitude: -122.2
      ride.set_distance_to_voter(driver.latitude, driver.longitude)
      get :status
      expect(JSON.parse(response.body)['response']).to eq(expected.merge('active_ride' => ride.api_json.as_json))
    end
  end

  describe 'accept ride' do
    let(:ride) { create :ride }

    it 'is successful' do
      post :accept_ride, params: {ride_id: ride.id}
      expect(response).to be_successful
    end

    it 'updates ride with driver' do
      post :accept_ride, params: {ride_id: ride.id}
      expect(ride.reload.driver_id).to eq(driver.id)
    end

    it 'updates ride status' do
      post :accept_ride, params: {ride_id: ride.id}
      expect(ride.reload.status).to eq('driver_assigned')
    end

    it 'does not allow stealing rides' do
      ride.assign_driver(create :driver_user, ride_zone: rz)
      post :accept_ride, params: {ride_id: ride.id}
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
    end
  end

  describe 'unaccept ride' do
    let(:ride) { create :ride, driver_id: driver.id }

    it 'is successful' do
      post :unaccept_ride, params: {ride_id: ride.id}
      expect(response).to be_successful
    end

    it 'updates ride to have no driver' do
      post :unaccept_ride, params: {ride_id: ride.id}
      expect(ride.reload.driver_id).to be_nil
    end

    it 'updates ride status' do
      post :unaccept_ride, params: {ride_id: ride.id}
      expect(ride.reload.status).to eq('waiting_assignment')
    end

    it 'does not allow unaccepting un-owned rides' do
      ride.update_attribute :driver_id, 999
      post :unaccept_ride, params: {ride_id: ride.id}
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
    end
  end

  describe 'pickup ride' do
    let(:ride) { create :ride, driver_id: driver.id }

    it 'is successful' do
      post :pickup_ride, params: {ride_id: ride.id}
      expect(response).to be_successful
    end

    it 'updates ride status' do
      post :pickup_ride, params: {ride_id: ride.id}
      expect(ride.reload.status).to eq('picked_up')
    end

    it 'does not allow picking up un-owned rides' do
      ride.update_attribute :driver_id, 999
      post :pickup_ride, params: {ride_id: ride.id}
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
    end
  end

  describe 'complete ride' do
    let(:ride) { create :ride, driver_id: driver.id }

    it 'is successful' do
      post :complete_ride, params: {ride_id: ride.id}
      expect(response).to be_successful
    end

    it 'updates ride status' do
      post :complete_ride, params: {ride_id: ride.id}
      expect(ride.reload.status).to eq('complete')
    end

    it 'does not allow completing un-owned rides' do
      ride.update_attribute :driver_id, 999
      post :complete_ride, params: {ride_id: ride.id}
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
    end

    it 'updates driver location' do
      post :complete_ride, params: car_location.merge(ride_id: ride.id)
      verify_location_updated
    end
  end

  describe 'waiting rides' do
    it 'is successful' do
      get :waiting_rides
      expect(response).to be_successful
    end

    it 'returns interval' do
      allow(controller).to receive(:waiting_rides_interval).and_return(42)
      get :waiting_rides
      expect(JSON.parse(response.body)['waiting_rides_interval']).to eq(42)
    end

    it 'returns rides' do
      lat = car_location[:latitude]
      long = car_location[:longitude]
      rides = create_list :waiting_ride, 3
      rides.each_with_index do |r, i|
        r.update_attributes(from_latitude: lat + i * 0.1, from_longitude: long + i * 0.1)
        r.set_distance_to_voter(lat, long)
      end
      driver.update_attributes car_location
      expect(Ride).to receive(:waiting_nearby).with(\
        rz.id,
        lat,
        long,
        DrivingController::RIDES_LIMIT,
        rz.nearby_radius).and_return(rides)
      get :waiting_rides
      expect(JSON.parse(response.body)['response']).to eq(rides.map {|r| r.api_json.as_json})
    end
  end

  describe 'zone stats' do
    it 'is successful' do
      get :ridezone_stats
      expect(response).to be_successful
    end

    it 'returns ridezone data' do
      expected = {foo: :bar}
      expect_any_instance_of(RideZone).to receive(:driving_stats).and_return(expected)
      get :ridezone_stats
      expect(JSON.parse(response.body)['response']).to eq(expected.as_json)
    end
  end
end
