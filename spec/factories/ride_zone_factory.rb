FactoryGirl.define do

  factory :ride_zone do
    sequence(:name) { |n| "Toldedo, District #{n}"  }
    sequence(:slug) { |n| "slug #{n}"}
    zip '15106'
    sequence(:phone_number) { |n| "207-867-%04d" % n }
    sequence(:email) { |n| "phu%04d@test.com" % n }
    time_zone 'America/New_York'
    nearby_radius 5
  end

end