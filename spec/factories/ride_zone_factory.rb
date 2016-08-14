FactoryGirl.define do

  factory :ride_zone do
    slug 'toledo_ohio_d_4'
    name 'Toldedo, District 4'
    zip '43601'
    sequence(:phone_number) { |n| '867-%04d' % n }
  end

end