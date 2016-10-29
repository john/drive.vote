FactoryGirl.define do

  factory :user do
    name 'Jamie Farr'
    sequence(:email) { |n| "james#{n}@example.com" }
    password '123456789'
    city 'Carnegie'
    state 'PA'
    zip '15106'
    sequence(:phone_number) { |n| "510-555-%04d" % n}

    factory :admin_user do
      user_type :admin
    end

    factory :zoned_admin_user do
      transient do
        rz { create( :ride_zone ) }
      end

      after(:create) do |user, evaluator|
        user.add_role( :admin, evaluator.rz)
      end
    end

    factory :voter do
      after(:create) do |user, evaluator|
        user.add_role(:voter)
      end
    end

    factory :driver_user do
      transient do
        rz { create( :ride_zone ) }
      end

      after(:create) do |user, evaluator|
        user.add_role( :driver, evaluator.rz )
      end
    end

    factory :dispatcher_user do
      transient do
        rz { create( :ride_zone ) }
      end

      after(:create) do |user, evaluator|
        user.add_role( :dispatcher, evaluator.rz )
      end
    end

    factory :zoned_driver_user do
      transient do
        rz { create( :ride_zone ) }
      end

      after(:create) do |user, evaluator|
        user.add_role( :driver, evaluator.rz)
      end
    end

    factory :unassigned_driver_user do
      transient do
        rz { create( :ride_zone ) }
      end

      after(:create) do |user, evaluator|
        user.add_role( :unassigned_driver, evaluator.rz )
        # user.add_role( :unassigned_driver )
      end
    end

    # factory :unassigned_driver_for_rz_user do
    #   user_type :unassigned_driver
    #   transient do
    #     rz { create( :ride_zone ) }
    #   end
    #
    #   after(:create) do |user, evaluator|
    #     user.add_role( :unassigned_driver, evaluator.rz )
    #   end
    # end

    factory :voter_user do
      transient do
        rz { create( :ride_zone ) }
      end

      user_type :voter
      locale :en

      after(:create) do |user, evaluator|
        user.add_role( :voter, evaluator.rz)
      end

      factory :sms_voter_user do
        phone_number '+15555551234'
        name User.sms_name('+15555551234')
      end
    end
  end
end
