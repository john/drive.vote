require 'rails_helper'

RSpec.describe DrivingController, :type => :controller do
  let(:rz) { create :ride_zone }
  let(:driver) { d = create :user; d.add_role(:driver, rz); d }
  let(:car_location) { {latitude: 35, longitude: -122} }

  before :each do
    controller.stub(:signed_in?).and_return(true)
    controller.stub(:current_user).and_return(driver)
  end

  def verify_location_updated
    driver.reload.latitude.should == car_location[:latitude]
    driver.longitude.should == car_location[:longitude]
  end

  describe 'update location' do
    it 'is successful' do
      post :update_location, params: car_location
      response.should be_successful
    end

    it 'updates driver location' do
      post :update_location, params: car_location
      verify_location_updated
    end

    it 'returns calculated interval' do
      controller.stub(:update_location_interval) { 42 }
      post :update_location, params: car_location
      JSON.parse(response.body)['update_location_interval'].should == 42
    end
  end

  describe 'set available' do
    before :each do
      driver.update_attribute :available, false
    end

    it 'is successful' do
      post :available, params: car_location
      response.should be_successful
    end

    it 'updates availability' do
      post :available, params: car_location
      driver.reload.available.should == true
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
      response.should be_successful
    end

    it 'updates availability' do
      post :unavailable, params: car_location
      driver.reload.available.should == false
    end
  end

  describe 'get status' do
    let(:expected) { {'available' => true, 'active_ride' => nil, 'waiting_rides_interval' => 24, 'update_location_interval' => 42} }
    before :each do
      driver.update_attribute :available, true
      controller.stub(:update_location_interval) { expected['update_location_interval'] }
      controller.stub(:waiting_rides_interval) { expected['waiting_rides_interval'] }
    end

    it 'is successful' do
      get :status
      response.should be_successful
    end

    it 'returns data when no ride' do
      get :status
      JSON.parse(response.body)['response'].should == expected
    end

    it 'returns data with ride' do
      ride = create :ride, status: :picked_up, driver: driver
      get :status
      JSON.parse(response.body)['response'].should == expected.merge('active_ride' => ride.api_json)
    end
  end

  describe 'accept ride' do
    let(:ride) { create :ride }

    it 'is successful' do
      post :accept_ride, params: {ride_id: ride.id}
      response.should be_successful
    end

    it 'updates ride with driver' do
      post :accept_ride, params: {ride_id: ride.id}
      ride.reload.driver_id.should == driver.id
    end

    it 'updates ride status' do
      post :accept_ride, params: {ride_id: ride.id}
      ride.reload.status.should == 'driver_assigned'
    end

    it 'does not allow stealing rides' do
      ride.update_attribute :driver_id, 999
      post :accept_ride, params: {ride_id: ride.id}
      response.should_not be_successful
      response.status.should == 400
    end
  end

  describe 'unaccept ride' do
    let(:ride) { create :ride, driver_id: driver.id }

    it 'is successful' do
      post :unaccept_ride, params: {ride_id: ride.id}
      response.should be_successful
    end

    it 'updates ride to have no driver' do
      post :unaccept_ride, params: {ride_id: ride.id}
      ride.reload.driver_id.should be_nil
    end

    it 'updates ride status' do
      post :unaccept_ride, params: {ride_id: ride.id}
      ride.reload.status.should == 'waiting_assignment'
    end

    it 'does not allow unaccepting un-owned rides' do
      ride.update_attribute :driver_id, 999
      post :unaccept_ride, params: {ride_id: ride.id}
      response.should_not be_successful
      response.status.should == 400
    end
  end

  describe 'pickup ride' do
    let(:ride) { create :ride, driver_id: driver.id }

    it 'is successful' do
      post :pickup_ride, params: {ride_id: ride.id}
      response.should be_successful
    end

    it 'updates ride status' do
      post :pickup_ride, params: {ride_id: ride.id}
      ride.reload.status.should == 'picked_up'
    end

    it 'does not allow picking up un-owned rides' do
      ride.update_attribute :driver_id, 999
      post :pickup_ride, params: {ride_id: ride.id}
      response.should_not be_successful
      response.status.should == 400
    end
  end

  describe 'complete ride' do
    let(:ride) { create :ride, driver_id: driver.id }

    it 'is successful' do
      post :complete_ride, params: {ride_id: ride.id}
      response.should be_successful
    end

    it 'updates ride status' do
      post :complete_ride, params: {ride_id: ride.id}
      ride.reload.status.should == 'complete'
    end

    it 'does not allow completing un-owned rides' do
      ride.update_attribute :driver_id, 999
      post :complete_ride, params: {ride_id: ride.id}
      response.should_not be_successful
      response.status.should == 400
    end

    it 'updates driver location' do
      post :complete_ride, params: car_location.merge(ride_id: ride.id)
      verify_location_updated
    end
  end

  describe 'waiting rides' do
    it 'is successful' do
      get :waiting_rides
      response.should be_successful
    end

    it 'returns interval' do
      controller.stub(:waiting_rides_interval) { 42 }
      get :waiting_rides
      JSON.parse(response.body)['waiting_rides_interval'].should == 42
    end

    it 'returns rides' do
      rides = create_list :waiting_ride, 3
      driver.update_attributes car_location
      Ride.should_receive(:waiting_nearby).with(\
        rz.id,
        car_location[:latitude],
        car_location[:longitude],
        DrivingController::RIDES_LIMIT,
        DrivingController::RIDES_RADIUS).and_return(rides)
      get :waiting_rides
      JSON.parse(response.body)['response'].should == rides.map {|r| r.api_json}
    end
  end

  describe 'zone stats' do
    it 'is successful' do
      get :ridezone_stats
      response.should be_successful
    end

    it 'returns ridezone data' do
      expected = {foo: :bar}
      RideZone.any_instance.should_receive(:driving_stats).and_return(expected)
      get :ridezone_stats
      JSON.parse(response.body)['response'].should == expected.as_json
    end
  end
end
