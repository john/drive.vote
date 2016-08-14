FactoryGirl.define do

  factory :user do
    name 'Jamie Farr'
    sequence(:email) { |n| "james#{n}@example.com" }
    password '123456789'
    city 'Toledo'
    state 'Oh'
    zip '43601'

    factory :admin_user do
      user_type :admin
    end

    factory :driver_user do
      user_type :driver
    end

    factory :unassigned_driver_user do
      user_type :unassigned_driver
    end

    factory :voter_user do
      user_type :voter

      factory :sms_voter_user do
        phone_number '+15555551234'
        name User.sms_name('+15555551234')
      end
    end
  end
end
