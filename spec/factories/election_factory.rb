FactoryGirl.define do
  
  factory :election do
    association :voter, factory: :voter_user
    name '2016 Presidential Election'
    slug 'pres16'
    description 'For the big one. Our supreme leader.'
    date DateTime.now
  end
  
end