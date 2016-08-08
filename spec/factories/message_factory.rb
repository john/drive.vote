FactoryGirl.define do

  factory :message do
    to 867-5309
    from 291-3213
    num_media 1
    num_segments 1
    body 'oh hai'
  end

end