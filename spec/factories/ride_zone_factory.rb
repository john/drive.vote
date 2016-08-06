FactoryGirl.define do

  factory :ride_zone do
    slug 'toledo_ohio'
    name 'Toledo, OH'
    sequence(:phone_number) { |n| '867-%04d' % n }
  end

end