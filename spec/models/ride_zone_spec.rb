require 'rails_helper'

RSpec.describe RideZone, type: :model do

  it { should have_many(:messages) }


  describe 'lifecycle hooks' do
    describe 'after_validation geocode' do
      let(:rz) { create :ride_zone }
      it 'should set lat/long on ride_zone create' do
        expect(rz.latitude).to_not be_nil
        expect(rz.longitude).to_not be_nil
      end

      it 'should update lat/long on zip change and ride_zone save' do
        original_lat = rz.latitude
        original_long = rz.longitude

        rz.zip = 43623

        rz.save!
        rz.reload

        expect(rz.latitude).to_not eq(original_lat)
        expect(rz.longitude).to_not eq(original_long)
      end
    end
  end

  it 'calculates stats' do
    rz = create :ride_zone
    rz2 = create :ride_zone
    d1 = create :driver_user, available: true, ride_zone: rz
    d2 = create :driver_user, available: false, ride_zone: rz
    d3 = create :driver_user, ride_zone: rz2

    Ride.statuses.each { |s| create :ride, ride_zone: rz, status: s[0]}
    Ride.statuses.each { |s| create :ride, ride_zone: rz2, status: s[0]} # should not be in counts
    expected = {
        total_drivers: 2,
        available_drivers: 1,
        completed_rides: 1,
        active_rides: 3,
        scheduled_rides: 1,
    }
    expect(rz.driving_stats).to eq(expected)
  end
end
