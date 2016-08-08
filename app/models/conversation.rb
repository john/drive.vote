class Conversation < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :user
  has_many :messages
  has_one :ride

  before_commit :update_lifecycle

  enum status: { in_progress: 0, ride_created: 1, closed: 2 }
  enum lifecycle: { need_language: 100, need_name: 200, need_origin: 300, need_destination: 400, need_time: 500, info_complete: 1000 }

  private
  def update_lifecycle
    new_lc = calculated_lifecycle
    update_attribute :lifecycle, new_lc if lifecycle != new_lc
  end

  def calculated_lifecycle
    if user.unknown_language?
      lckey = :need_language
    elsif user.name.blank? || user.has_sms_name?
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
