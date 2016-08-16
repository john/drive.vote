FactoryGirl.define do

  factory :ride_zone do
    sequence(:slug) { |n| "toledo_ohio_d_#{n}" }
    sequence(:name) { |n| "Toldedo, District #{n}"  }
    zip '43601'
    sequence(:phone_number) { |n| "867-530#{n}" }
  end

end