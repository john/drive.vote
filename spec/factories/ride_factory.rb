FactoryGirl.define do

  factory :ride do
    ride_zone
    status 0
    association :voter, factory: :voter_user
    name "Doug's ride"
    description 'Needs to get to work before 9am'

    factory :scheduled_ride do
      status Ride.statuses[:scheduled]
    end

    factory :waiting_ride do
      status Ride.statuses[:waiting_assignment]
    end

    factory :assigned_ride do
      status Ride.statuses[:driver_assigned]
    end

    factory :picked_up_ride do
      status Ride.statuses[:picked_up]
    end

    factory :complete_ride do
      status Ride.statuses[:complete]
    end
  end

end