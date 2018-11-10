FactoryBot.define do

  factory :potential_ride do
    voter {create :user}
    ride_zone {create :ride_zone, zip: '93510', time_zone: 'America/Los_Angeles', nearby_radius: 50}
    ride_upload {create :ride_upload}
    name {'Rob Reider'}
    email {'robreider@test.com'}
    phone_number {'555.555.5556'}
    pickup_at {'2018-11-06 08:00:00'}
    from_address {'410-448 E Ave Q'}
    from_city {'Palmdale'}
    from_state {'CA'}
    status {0}
  end

end
