require 'rails_helper'

RSpec.describe RideZone, type: :model do

  it { should have_many(:messages) }


  describe 'lifecycle hooks' do
    # note we cannot rely on VCR for http calls to timezone b/c it adds a timestamp
    # to every call
    describe 'after_validation geocode and timezone' do
      let(:rz) { create :ride_zone }
      it 'should set lat/long on ride_zone create' do
        expect(rz.latitude).to_not be_nil
        expect(rz.longitude).to_not be_nil
      end

      it 'should set utc offset' do
        expect(Timezone).to receive(:lookup).and_return(OpenStruct.new(utc_offset: 999))
        expect(rz.utc_offset).to eq(999)
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

      it 'should update time zone on zip change' do
        expect(Timezone).to receive(:lookup).and_return(OpenStruct.new(utc_offset: 999))
        original_utc_offset = rz.utc_offset
        rz.zip = 94111
        rz.save!
        expect(rz.reload.utc_offset).to eq(999)
      end
    end
  end

  it 'active_rides returns active rides' do
    rz = create :ride_zone
    r = create :waiting_ride, ride_zone_id: rz.id

    expect( rz.active_rides.first ).to eq(r)
  end

  it 'active_rides does not return inactive rides' do
    rz = create :ride_zone
    cr = create :complete_ride, ride_zone_id: rz.id

    expect( rz.active_rides.first ).to be_nil
  end

  it 'returns unavailable_drivers' do
    d = create :zoned_driver_user
    rz = RideZone.with_role(:driver, d).first
    cr = create :assigned_ride, ride_zone_id: rz.id, driver_id: d.id

     expect( rz.unavailable_drivers.first ).to eq(d)
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
