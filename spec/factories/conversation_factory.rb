FactoryGirl.define do

  factory :conversation do
    user

    sequence(:to_phone) { |n| "212-867-%04d" % n }
    sequence(:from_phone) { |n| "310-567-%04d" % n }

    ride_zone {create :ride_zone, phone_number: to_phone}

    factory :conversation_with_messages do
      transient do
        messages_count 2
      end

      after(:create) do |conversation, evaluator|
        create_list(:message,
                    evaluator.messages_count,
                    conversation: conversation,
                    to: conversation.to_phone,
                    from: conversation.from_phone,
                    ride_zone: conversation.ride_zone)
      end
    end

    factory :closed_conversation do
      status :closed
    end
    
    factory :convo_with_blacklisted_number do
      after(:create) do |conversation, evaluator|
        BlacklistedPhone.new(phone: 1234567)
      end
    end

    factory :complete_conversation do
      from_phone '2073328709'
      from_address 'fake_address'
      from_city 'fake_city'
      from_latitude 40.409
      from_longitude -80.090
      from_confirmed true
      to_latitude 41.410
      to_longitude -80.190
      to_confirmed true
      pickup_at Time.now
      time_confirmed true
      additional_passengers 0
      special_requests 'None'
      after(:create) do |conversation, evaluator|
        conversation.user.update_attribute(:language, :en) if conversation.user.language == 'unknown'
      end
    end
  end

end