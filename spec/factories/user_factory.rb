FactoryGirl.define do

  factory :user do
    name 'Bella Abzug'
    sequence(:email) { |n| 'bella%04d@example.com' % n }
    password '123456789'
    city 'New York'
    state 'NY'
  end

  # set up roles for this soon
  factory :admin_user, class: User do
    name 'Barack Obama'
    email 'barack@example.com'
    password '345678901'
    city 'Chicago'
    state 'IL'

    after(:create) do |admin_user|
      admin_user.add_role( :admin )
    end
  end

end
