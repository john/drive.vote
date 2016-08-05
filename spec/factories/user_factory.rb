FactoryGirl.define do

  factory :user do
    name 'Bella Abzug'
    email 'bella@gmail.com'
    password '123456789'
    city 'New York'
    state 'NY'
  end

  # set up roles for this soon
  factory :admin_user, class: User do
    name 'Barack Obama'
    email 'barack@gmail.com'
    password '345678901'
    city 'Chicago'
    state 'IL'

    after(:create) do |admin_user|
      admin_user.add_role( :admin )
    end
  end

end