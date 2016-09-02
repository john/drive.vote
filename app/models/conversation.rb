class Conversation < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :user
  has_many :messages
  belongs_to :ride

  before_save :check_ride_attached
  before_save :update_status_and_lifecycle
  before_save :note_status_update
  after_create :notify_creation
  around_save :notify_update

  validate :phone_numbers_match_first_message
  include HasAddress
  include ToFromAddressable

  enum status: { sms_created: -1, in_progress: 0, ride_created: 1, closed: 2, help_needed: 3 }
  enum lifecycle: {
    created: 0,
    have_language: 100,
    have_name: 200,
    have_prior_ride: 250,
    have_origin: 300,
    have_confirmed_origin: 400,
    have_destination: 500,
    have_confirmed_destination: 600,
    have_time: 700,
    have_confirmed_time: 800,
    have_passengers: 900,
    info_complete: 1000,
  }

  def api_json(include_messages = false)
    fields = [:id, :user_id, :pickup_at, :status, :lifecycle, :from_phone, :from_address, :from_city,
              :from_latitude, :from_longitude, :to_address, :to_city,
              :to_latitude, :to_longitude, :additional_passengers, :special_requests]
    j = self.as_json(only: fields, methods: [:message_count])
    if include_messages
      j['messages'] = self.messages.map(&:api_json)
    end
    last_msg = self.messages.order('created_at ASC').last
    if last_msg
      j['last_message_time'] = last_msg.created_at.to_i
      j['last_message_sent_by'] = last_msg.sent_by
      j['last_message_body'] = last_msg.body
    end
    j['from_phone'] = self.from_phone.phony_formatted(normalize: :US, spaces: '-')
    j['status_updated_at'] = self.status_updated_at.to_i
    j['name'] = username
    j['ride'] = ride.api_json if ride
    j
  end

  # send a new SMS from staff on this conversation. returns the Message
  def send_from_staff(body, timeout)
    sms = Conversation.send_staff_sms(ride_zone, user, body, timeout)
    return sms if sms.is_a?(String)
    Message.create_from_staff(self, sms)
  end

  # create a new conversation initiated by staff
  # returns conversation if successful otherwise an error message
  def self.create_from_staff(ride_zone, user, body, timeout, attrs = {})
    sms = send_staff_sms(ride_zone, user, body, timeout)
    return sms if sms.is_a?(String)
    c = Conversation.create({ride_zone: ride_zone, user: user, from_phone: ride_zone.phone_number_normalized,
                            to_phone: user.phone_number_normalized, status: :in_progress}.merge(attrs))
    msg = Message.create_from_staff(c, sms)
    c
  end

  def self.send_staff_sms(ride_zone, user, body, timeout)
    sms = TwilioService.send_message(
        { from: ride_zone.phone_number_normalized, to: user.phone_number, body: body},
        timeout
    )
    if sms.error_code
      return "Communication error #{sms.error_code}"
    elsif sms.status.to_s != 'delivered'
      return 'Timeout in delivery'
    end
    sms
  end

  def username
    if self.user && !self.user.has_sms_name?
      self.user.name
    else
      ''
    end
  end

  def message_count
    self.messages.count
  end

  # a conversation is staff initiated if the "from" phone number matches
  # the ride zone twilio-assigned number
  def staff_initiated?
    self.from_phone == self.ride_zone.phone_number_normalized
  end

  def set_unknown_destination
    self.to_address = UNKNOWN_ADDRESS
    self.to_confirmed = true
  end

  def invert_ride_addresses(ride)
    self.from_address = ride.to_address
    self.from_city = ride.to_city
    self.from_latitude = ride.to_latitude
    self.from_longitude = ride.to_longitude
    self.to_address = ride.from_address
    self.to_city = ride.from_city
    self.to_latitude = ride.from_latitude
    self.to_longitude = ride.from_longitude
    self.from_confirmed = self.to_confirmed = true
    save
  end

  def self.active_statuses
    Conversation.statuses.keys - ['closed']
  end

  private
  def notify_creation
    rz_id = self.ride_zone_id || self.ride_zone.try(:id)
    RideZone.event(rz_id, :new_conversation, self) if rz_id
  end

  def notify_update
    was_new = new_record?
    yield
    rz_id = self.ride_zone_id || self.ride_zone.try(:id)
    RideZone.event(rz_id, :conversation_changed, self) if !was_new && rz_id
  end

  def check_ride_attached
    if ride_id_changed? && ride_id
      self.status = :ride_created
    end
  end

  def update_status_and_lifecycle
    self.status = :in_progress if self.status == 'sms_created' && !new_record?
    self.lifecycle = calculated_lifecycle unless lifecycle_changed?
  end

  def note_status_update
    self.status_updated_at = Time.now if new_record? || self.status_changed?
  end

  def calculated_lifecycle
    if user.unknown_language?
      lckey = :created
    elsif user.name.blank? || user.has_sms_name?
      lckey = :have_language
    elsif !ignore_prior_ride && user.recent_complete_ride && !user.recent_complete_ride.has_unknown_destination? && from_latitude.nil?
      lckey = :have_prior_ride
    elsif from_latitude.nil? || from_longitude.nil?
      lckey = :have_name
    elsif !from_confirmed
      lckey = :have_origin
    elsif has_unknown_destination? && pickup_time.nil? && !time_confirmed
      lckey = :have_confirmed_destination
    elsif (to_latitude.nil? || to_longitude.nil?) && !has_unknown_destination?
      lckey = :have_confirmed_origin
    elsif !to_confirmed
      lckey = :have_destination
    elsif pickup_time.nil?
      lckey = :have_confirmed_destination
    elsif !time_confirmed
      lckey = :have_time
    elsif additional_passengers.nil?
      lckey = :have_confirmed_time
    elsif special_requests.nil?
      lckey = :have_passengers
    else
      lckey = :info_complete
    end
    Conversation.lifecycles[lckey]
  end

  def phone_numbers_match_first_message
    first_message = self.messages.order(:created_at).first
    unless first_message.nil?
      unless self.to_phone == first_message.to
        errors.add(:to_phone, 'must match :to attribute of first Message')
      end
      unless self.from_phone == first_message.from
        errors.add(:from_phone, 'must match :from attribute of first Message')
      end
    end
  end
end
