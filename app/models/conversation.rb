class Conversation < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :user
  has_many :messages
  has_one :ride

  before_save :update_lifecycle
  after_create :notify_creation
  around_save :notify_update

  enum status: { in_progress: 0, ride_created: 1, closed: 2 }
  enum lifecycle: { need_language: 100, need_name: 200, need_origin: 300, need_destination: 400, need_time: 500, info_complete: 1000 }

  def api_json(include_messages = false)
    j = self.as_json(only: [:id, :pickup_at, :status, :name, :from_phone, :from_address, :from_city, :to_address, :to_city])
    j['messages'] = self.messages.map(&:api_json) if include_messages
    j
  end

  def self.active_statuses
    Conversation.statuses.keys - ['closed']
  end

  private
  def notify_creation
    self.ride_zone.event(:new_conversation, self) if self.ride_zone
  end

  def notify_update
    was_new = new_record?
    yield
    self.ride_zone.event(:conversation_changed, self) if !was_new && self.ride_zone
  end

  def update_lifecycle
    self.lifecycle = calculated_lifecycle
  end

  def calculated_lifecycle
    if user.unknown_language?
      lckey = :need_language
    elsif user.name.blank?
      lckey = :need_name
    elsif from_latitude.nil? || from_longitude.nil?
      lckey = :need_origin
    elsif to_latitude.nil? || to_longitude.nil?
      lckey = :need_destination
    elsif pickup_time.nil?
      lckey = :need_time
    else
      lckey = :info_complete
    end
    Conversation.lifecycles[lckey]
  end
end
