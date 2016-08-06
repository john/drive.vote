require 'rails_helper'

RSpec.describe Ride, type: :model do

  it { should belong_to(:ride_zone) }
  it { should validate_presence_of(:owner_id) }

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
