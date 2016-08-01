FactoryGirl.define do
  
  factory :election do
    owner_id 1
    name '2016 Presidential Election'
    slug 'pres16'
    description 'For the big one. Our supreme leader.'
    date DateTime.now
  end
  
end