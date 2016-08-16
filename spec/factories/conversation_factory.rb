FactoryGirl.define do

  factory :conversation do
    user

    sequence(:to_phone) { |n| "213-111-111#{n}" }
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
      to_latitude 34.5
      to_longitude -122.6
      pickup_time Time.now
    end
  end

end