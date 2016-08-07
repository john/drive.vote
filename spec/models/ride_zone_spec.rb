require 'rails_helper'

RSpec.describe RideZone, type: :model do

  it { should have_many(:messages) }

  it 'calculates stats' do
    rz = create :ride_zone
    rz2 = create :ride_zone
    d1 = create :user, available: true
    d2 = create :user, available: false
    d3 = create :user # not in this rz
    d1.add_role(:driver, rz)
    d2.add_role(:driver, rz)

    Ride.statuses.each { |s| create :ride, ride_zone: rz, status: s[0]}
    Ride.statuses.each { |s| create :ride, ride_zone: rz2, status: s[0]} # should not be in counts
    expected = {
        total_drivers: 2,
        available_drivers: 1,
        completed_rides: 1,
        active_rides: 3,
        scheduled_rides: 1,
    }
    rz.driving_stats.should == expected
  end
end
