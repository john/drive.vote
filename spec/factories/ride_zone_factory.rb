FactoryGirl.define do

  factory :ride_zone do
    sequence(:name) { |n| "Toldedo, District #{n}"  }
    zip '43601'
    sequence(:phone_number) { |n| "867-530#{n}" }
    utc_offset Time.now.utc_offset # has to be set to time zone where test is run
  end

end