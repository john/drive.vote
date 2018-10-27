FactoryGirl.define do

  factory :ride_upload do
    name 'test ride upload foo good'
    user {create :user}
    ride_zone {create :ride_zone}
    status 0
    
    factory :ride_upload_with_csv, parent: :ride_upload do
      after(:build) do |ride_upload_with_csv|
        ride_upload_with_csv.csv.attach(io: File.open(Rails.root.join('spec', 'factories', 'files', 'test_ride_upload_valid.csv')), filename: 'test_ride_upload_valid.csv', content_type: 'text/csv')
      end
    end
    
    factory :ride_upload_with_non_csv, parent: :ride_upload do
      after(:build) do |ride_upload_with_non_csv|
        ride_upload_with_non_csv.csv.attach(io: File.open(Rails.root.join('spec', 'factories', 'files', 'isetta.jpeg')), filename: 'isetta.jpeg', content_type: 'image/jpeg')
      end
    end
    
  end

end
