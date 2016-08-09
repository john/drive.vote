FactoryGirl.define do

  factory :user do
    ignore do
      ride_zone nil
    end

    name 'Bella Abzug'
    sequence(:email) { |n| 'bella%04d@example.com' % n }
    password '123456789'
    city 'New York'
    state 'NY'

    factory :admin_user do
      after(:create) do |admin_user, eval|
        admin_user.add_role(:admin, eval.ride_zone )
      end
    end

    factory :driver_user do
      after(:create) do |driver_user, eval|
        driver_user.add_role(:driver, eval.ride_zone )
      end
    end

    factory :voter_user do
      after(:create) do |voter_user, eval|
        voter_user.add_role(:voter, eval.ride_zone )
      end
    end
  end
end
