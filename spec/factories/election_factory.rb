FactoryGirl.define do
  
  factory :election do
    name '2016 Presidential Election'
    slug 'pres16'
    description 'For the big one. Our supreme leader.'
    date DateTime.now
  end
  
end