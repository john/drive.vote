FactoryGirl.define do

  factory :ride_zone do
    sequence(:name) { |n| "Carnegie, District #{n}"  }
    sequence(:slug) { |n| "slug_#{n}"}
    zip '15106'
    sequence(:phone_number) { |n| "207-867-%04d" % n }
    sequence(:email) { |n| "phu%04d@test.com" % n }
    time_zone 'America/New_York'
    nearby_radius 5
    max_pickup_radius 50
  end

end