FactoryGirl.define do

  factory :ride_zone do
    sequence(:name) { |n| "Toldedo, District #{n}"  }
    sequence(:slug) { |n| "slug #{n}"}
    zip '43601'
    sequence(:phone_number) { |n| "867-530#{n}" }
    time_zone 'America/New_York'
  end

end