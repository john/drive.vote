FactoryGirl.define do
  
  factory :message do
    to 867-5309
    to_city 'Toledo'
    to_state 'OH'
    from 29
    num_media 1
    num_segments 1
    body 'oh hai'
  end
  
end