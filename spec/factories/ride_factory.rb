FactoryGirl.define do

  factory :ride do
    ride_zone
    status 0
    owner_id 1
    name "Doug's ride"
    description 'Needs to get to work before 9am'

    factory :waiting_ride do
      status Ride.statuses[:waiting_pickup]
    end
  end

end