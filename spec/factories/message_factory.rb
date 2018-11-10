FactoryBot.define do

  factory :message do
    to {'213-867-5309'}
    from {'310-291-3213'}
    num_media {1}
    num_segments {1}
    sequence(:body) { |n| "oh hai, message ##{n}" }
  end

end
