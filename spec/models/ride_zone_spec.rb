require 'rails_helper'

RSpec.describe RideZone, type: :model do

  it { should have_many(:conversations) }
  it { should have_many(:messages) }
  it { should have_many(:rides) }

  describe 'lifecycle hooks' do
    # note we cannot rely on VCR for http calls to timezone b/c it adds a timestamp
    # to every call
    describe 'after_validation geocode, reverse geocode, and timezone' do
      let(:rz) { create :ride_zone }
      it 'should set lat/long on ride_zone create' do
        expect(rz.latitude).to_not be_nil
        expect(rz.longitude).to_not be_nil
      end

      it 'should set state and country on ride_zone create' do
        expect(rz.state).to_not be_nil
        expect(rz.country).to_not be_nil
      end

      it 'should set time zone' do
        expect(Timezone).to receive(:lookup).and_return(OpenStruct.new(name: 'Hawaii'))
        expect(rz.time_zone).to eq('Hawaii')
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
        expect(Timezone).to receive(:lookup).and_return(OpenStruct.new(name: 'Hawaii'))
        rz.zip = 94111
        rz.save!
        expect(rz.reload.time_zone).to eq('Hawaii')
      end

    end
  end

  it 'returns only its drivers' do
    rz = create :ride_zone
    rzd1 = create :driver_user, rz: rz
    rzd2 = create :driver_user, rz: rz
    d3 = create :driver_user # different ride zone
    d4 = create :user
    d4.add_role(:driver) # not scoped to a ride zone

    expect(rz.drivers.count).to eq(2)
    expect(rz.drivers.map(&:id)).to eq([rzd1.id, rzd2.id])
  end

  it 'returns ride zones with a user in a role' do
    rz1, rz2, rz3 = create(:ride_zone), create(:ride_zone), create(:ride_zone)
    d1 = create :user
    d1.add_role(:driver, rz1)
    d1.add_role(:driver, rz3)

    expect(RideZone.with_user_in_role(d1, :driver).count).to eq(2)
    expect(RideZone.with_user_in_role(d1, :driver).map(&:id)).to eq([rz1.id, rz3.id])
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

  it 'returns nearby available drivers' do
    driver = create :zoned_driver_user
    rz = RideZone.with_user_in_role(driver, :driver).first

     expect( rz.available_drivers(all: true).first ).to eq(driver)
  end

  it 'do not return distant drivers' do
    driver = create( :zoned_driver_user, city: 'Philadelphia', state: 'PA' )
    rz = RideZone.with_user_in_role(driver, :driver).first

     expect( rz.available_drivers.first ).to eq(nil)
  end

  it 'returns all available drivers' do
    driver = create( :zoned_driver_user, city: 'Pittsburgh', state: 'PA' )
    rz = RideZone.with_user_in_role(driver, :driver).first

     expect( rz.available_drivers(all: true).first ).to eq(driver)
  end

  it 'returns unavailable_drivers' do
    d = create :zoned_driver_user
    rz = RideZone.with_user_in_role(d, :driver).first
    cr = create :assigned_ride, ride_zone_id: rz.id, driver_id: d.id

     expect( rz.unavailable_drivers.first ).to eq(d)
  end

  describe 'pickup radius' do
    let(:rz) { create :ride_zone, max_pickup_radius: 1, latitude: 34, longitude: -122 }

    it 'reports nearby points as within radius' do
      expect(rz.is_within_pickup_radius?(34.001, -122.001)).to be_truthy
    end

    it 'reports farther points as outside radius' do
      expect(rz.is_within_pickup_radius?(35, -123)).to be_falsey
    end

    it 'returns true if no ride zone lat/long' do
      rz.update_attributes({latitude: nil, longitude: nil})
      expect(rz.is_within_pickup_radius?(35, -123)).to be_truthy
    end
  end

  it 'calculates stats' do
    rz = create :ride_zone
    rz2 = create :ride_zone
    d1 = create :driver_user, available: true, rz: rz
    d2 = create :driver_user, available: false, rz: rz
    d3 = create :driver_user, rz: rz2

    Ride.statuses.each { |s| create :ride, ride_zone: rz, status: s[0]}
    Ride.statuses.each { |s| create :ride, ride_zone: rz2, status: s[0]} # should not be in counts
    expected = {
        total_drivers: 2,
        available_drivers: 1,
        completed_rides: 1,
        active_rides: 4,
        scheduled_rides: 1,
    }
    expect(rz.driving_stats).to eq(expected)
  end
end
