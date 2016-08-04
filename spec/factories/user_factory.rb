FactoryGirl.define do

  factory :user do
    name 'Bella Abzug'
    email 'bella@gmail.com'
    password '123456789'
    city 'New York'
    state 'NY'
  end

  # set up roles for this soon
  factory :admin_user do
    name 'Barack Obama'
    email 'barack@gmail.com'
    password '0123456789'
    uid '323456789'
    provider 'facebook'
    city 'Chicago'
    state 'IL'
  end

end