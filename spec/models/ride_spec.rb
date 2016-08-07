require 'rails_helper'

RSpec.describe Ride, type: :model do

  it { should belong_to(:ride_zone) }
  it { should validate_presence_of(:owner_id) }

  describe 'driver functions' do
    let(:rz) { create :ride_zone }
    let(:ride) { create :ride, ride_zone: rz }
    let(:driver) { u = create :user; u.add_role(:driver, rz); u }
    let(:driver2) { u = create :user; u.add_role(:driver, rz); u }

    it 'assigns driver' do
      ride.assign_driver(driver).should be_truthy
      ride.reload.driver_id.should == driver.id
      ride.status.should == 'driver_assigned'
    end

    it 'does not assign driver if already has one' do
      ride.assign_driver(driver).should be_truthy
      ride.assign_driver(driver2).should be_falsey
      ride.reload.driver_id.should == driver.id
      ride.status.should == 'driver_assigned'
    end

    it 'clears driver' do
      ride.assign_driver(driver).should be_truthy
      ride.clear_driver(driver).should be_truthy
      ride.reload.driver_id.should be_nil
      ride.status.should == 'waiting_assignment'
    end

    it 'does not clear different driver' do
      ride.assign_driver(driver).should be_truthy
      ride.clear_driver(driver2).should be_falsey
      ride.reload.driver_id.should == driver.id
      ride.status.should == 'driver_assigned'
    end

    it 'picks up by driver' do
      ride.assign_driver(driver).should be_truthy
      ride.pickup_by(driver).should be_truthy
      ride.reload.status.should == 'picked_up'
    end

    it 'does not pick up with different driver' do
      ride.assign_driver(driver).should be_truthy
      ride.pickup_by(driver2).should be_falsey
      ride.reload.status.should == 'driver_assigned'
    end

    it 'completes up by driver' do
      ride.assign_driver(driver).should be_truthy
      ride.complete_by(driver).should be_truthy
      ride.reload.status.should == 'complete'
    end

    it 'does not complete with different driver' do
      ride.assign_driver(driver).should be_truthy
      ride.complete_by(driver2).should be_falsey
      ride.reload.status.should == 'driver_assigned'
    end
  end

  describe 'waiting nearby' do
    let!(:zone) { create :ride_zone }
    let!(:other_zone) { create :ride_zone }
    let!(:empty_zone) { create :ride_zone }
    let!(:rnotwaiting) { create :ride, from_latitude: 35, from_longitude: -122, ride_zone: zone }
    let!(:rotherzone) { create :waiting_ride, from_latitude: 35, from_longitude: -122, ride_zone: other_zone }
    let!(:r1) { create :waiting_ride, from_latitude: 35.1, from_longitude: -122.1, ride_zone: zone }
    let!(:r2) { create :waiting_ride, from_latitude: 35.5, from_longitude: -122.4, ride_zone: zone }
    let!(:r3) { create :waiting_ride, from_latitude: 35.2, from_longitude: -122.2, ride_zone: zone }
    let!(:r4) { create :waiting_ride, from_latitude: 35.3, from_longitude: -122.3, ride_zone: zone }

    it 'returns empty if no waiting rides' do
      Ride.waiting_nearby(empty_zone.id, 35, -122, 10, 100).should ==([])
    end

    it 'returns ordered set of rides with limit' do
      Ride.waiting_nearby(zone.id, 35, -122, 3, 100).should ==([r1, r3, r4])
    end

    it 'checks radius' do
      Ride.waiting_nearby(zone.id, 35, -122, 3, 0.1).should ==([])
    end
  end
end
