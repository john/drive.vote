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
      conversation: conversation,
      ride_zone: conversation.ride_zone,
      from: conversation.to_phone,
      to: conversation.from_phone,
      sms_sid: twilio_msg.sid,
      sms_status: twilio_msg.status,
      body: twilio_msg.body,
    }
    # whenever a manual reply is sent to a conversation mark it so bot doesn't act on it any more
    conversation.update_attribute(:status, :help_needed) if conversation.status == 'in_progress'
    Message.create!(attrs)
  end

  # creates a new Message object that is a staff-initiated conversation
  def self.create_from_staff(conversation, twilio_msg)
    Message.create!(attrs_for_conversation_twilio_msg(conversation, twilio_msg))
  end

  # creates a new Message object that will appear to have come from the bot
  def self.create_from_bot(conversation, twilio_msg)
    Message.create!(attrs_for_conversation_twilio_msg(conversation, twilio_msg).merge(sms_status: ''))
  end

  # reduced set of fields required for API
  def api_json
    {
      'id' => self.id,
      'conversation_id' => self.conversation.id,
      'conversation_message_count' => self.conversation.messages.count,
      'from_phone' => self.from,
      'to_phone' => self.to,
      'sent_by' => self.sent_by,
      'body' => self.body,
      'created_at' => self.created_at.to_i,
    }
  end

  def sent_by
    if self.to.phony_formatted == self.ride_zone.phone_number.phony_formatted
      if self.conversation.user.has_role?(:driver, self.ride_zone)
        'Driver'
      else
        'Voter'
      end
    elsif self.sms_status.blank?
      'Bot' # bot messages are replies to twilio and so don't have an sms_status
    else
      'Staff'
    end
  end

  def ride_zone
    self.conversation.try(:ride_zone)
  end

  private
  def notify_creation
    rz_id = self.ride_zone_id || self.ride_zone.try(:id)
    RideZone.event(rz_id, :new_message, self) if rz_id
    RideZone.event(rz_id, :conversation_changed, self.conversation) if rz_id
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
    rz_id = self.ride_zone_id || self.ride_zone.try(:id)
    RideZone.event(rz_id, :message_changed, self) if !was_new && rz_id
  end

  def self.attrs_for_conversation_twilio_msg(conversation, twilio_msg)
    {
      conversation: conversation,
      ride_zone: conversation.ride_zone,
      from: conversation.from_phone,
      to: conversation.to_phone,
      sms_sid: twilio_msg.sid,
      sms_status: twilio_msg.status,
      body: twilio_msg.body,
    }
  end
end
