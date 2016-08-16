class Message < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :conversation

  enum status: { unassigned: 0, inprogress: 1, closed: 2 }

  after_create :notify_creation

  validates :conversation, presence: true
  validate :conversation_has_correct_phone_numbers

  around_save :notify_update

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
      'to_phone' => self.to,
      'is_from_voter' => self.is_from_voter?,
      'body' => self.body,
      'created_at' => self.created_at.to_i,
    }
  end

  def is_from_voter?
    self.conversation.to_phone.phony_formatted == self.to.phony_formatted
  end

  def ride_zone
    self.conversation.try(:ride_zone)
  end

  private
  def notify_creation
    self.ride_zone.event(:new_message, self) if self.ride_zone
  end

  def conversation_has_correct_phone_numbers
    if !self.conversation.nil? && self.conversation.messages.empty?
      # we are first
      errors.add(:to, 'must match Conversation :to_phone') unless self.to == self.conversation.to_phone
      errors.add(:from, 'must match Conversation :from_phone') unless self.from == self.conversation.from_phone
    end
  end

  def notify_update
    was_new = new_record?
    yield
    self.ride_zone.event(:message_changed, self) if !was_new && self.ride_zone
  end
end
