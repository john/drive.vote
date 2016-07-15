FactoryGirl.define do
  
  factory :user do
    name 'Bella Abzug'
    email 'bella@gmail.com'
    password '123456789'
    uid '123456789'
    provider 'facebook'
    city 'New York'
    state 'NY'
  end
  
end