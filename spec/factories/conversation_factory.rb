FactoryGirl.define do

  factory :conversation do
    user

    sequence(:to_phone) { |n| "212-867-%04d" % n }
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
                    from: conversation.from_phone)
      end
    end

    factory :closed_conversation do
      status :closed
    end

    factory :complete_conversation do
      from_latitude 34.5
      from_longitude -122.6
      from_confirmed true
      to_latitude 34.5
      to_longitude -122.6
      to_confirmed true
      pickup_time Time.now
      time_confirmed true
      additional_passengers 0
      special_requests 'None'
    end
  end

end