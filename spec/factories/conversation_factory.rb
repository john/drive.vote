FactoryGirl.define do

  factory :conversation do
    user
    ride_zone {create :ride_zone, phone_number: '+14193860121'}
    from_phone '+15105555555'
    to_phone '+14193860121'

    factory :complete_conversation do
      from_latitude 34.5
      from_longitude -122.6
      to_latitude 34.5
      to_longitude -122.6
      pickup_time Time.now
    end
  end

end