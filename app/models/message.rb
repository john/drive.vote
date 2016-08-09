class Message < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :conversation

  enum status: { unassigned: 0, inprogress: 1, closed: 2 }

  # # scope by messagestatuses
  # scope :unassigned, -> { where(status: :unassigned) }

  # creates a new Message object that is a reply to a voter in a conversation
  def self.create_conversation_reply(conversation, twilio_msg)
    attrs = {
      conversation_id: conversation.id,
      ride_zone: conversation.ride_zone,
      from: conversation.to_phone,
      to: conversation.from_phone,
      sms_sid: twilio_msg.sid,
      sms_status: twilio_msg.status,
      body: twilio_msg.body,
    }
    Message.create!(attrs)
  end

  # reduced set of fields required for API
  def api_json
    {
      'id' => self.id,
      'conversation_id' => self.conversation_id,
      'from_phone' => self.from,
      'is_from_voter' => self.is_from_voter?,
      'body' => self.body,
      'created_at' => self.created_at.to_i,
    }
  end

  def is_from_voter?
    self.conversation.to_phone == self.ride_zone.phone_number
  end
end
