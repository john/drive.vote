class Conversation < ApplicationRecord
  include HasAddress
  include ToFromAddressable

  belongs_to :ride_zone
  belongs_to :user
  has_many :messages, dependent: :destroy
  belongs_to :ride
  has_one :blacklisted_phone

  before_save :check_ride_attached
  before_save :update_status_and_lifecycle
  before_save :note_status_update
  after_create :notify_creation
  around_save :notify_update

  validate :phone_numbers_match_first_message
  validate :validate_voter_phone_not_blacklisted

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
    requested_confirmation: 1100,
  }
  
  def api_json(include_messages = false)
    fields = [:id, :user_id, :pickup_at, :status, :lifecycle, :from_phone,
              :from_latitude, :from_longitude, :to_latitude, :to_longitude, :additional_passengers, :blacklisted_phone_number]
    j = self.as_json(only: fields, methods: [:message_count])
    if include_messages
      j['messages'] = self.messages.map(&:api_json)
    end
    %w(from_address from_city to_address to_city special_requests ).each do |field|
      j[field] = CGI::escape_html(send(field) || '')
    end
    last_msg = self.messages.order('created_at ASC').last
    if last_msg
      j['last_message_time'] = last_msg.created_at.to_i
      j['last_message_sent_by'] = last_msg.sent_by
      j['last_message_body'] = CGI::escape_html(last_msg.body || '')
    end
    j['from_phone'] = self.from_phone.phony_formatted(normalize: :US, spaces: '-')
    j['status_updated_at'] = self.status_updated_at.to_i
    j['name'] = CGI::escape_html(username || '')
    j['ride'] = ride.api_json if ride
    j['blacklisted_phone_number'] = self.blacklisted_phone.phone if self.blacklisted_phone.present?
    j
  end

  # have language and name and confirmed origin and destination and confirmed time and passengers
  def has_fields_for_ride
    if self.user.blank? ||
      # self.user.name.blank? ||
      self.from_address.blank? ||
      self.from_city.blank? ||
      self.from_latitude.blank? ||
      self.from_longitude.blank? ||
      self.pickup_at.blank?
      false
    else
      true
    end
  end

  # send a new SMS from staff on this conversation. returns the Message
  def send_from_staff(body, timeout)
    sms = Conversation.send_staff_sms(ride_zone, user, body, timeout)
    return sms if sms.is_a?(String)
    Message.create_from_staff(self, sms)
  end

  # create a new conversation from the information in a completed ride object
  def self.create_from_ride(ride, thanks_msg)
    attrs = Conversation.ride_conversation_attrs(ride)
    create_from_staff(ride.ride_zone, ride.voter, thanks_msg, Rails.configuration.twilio_timeout, attrs)
  end

  # sets all fields in the conversation as completed based on ride info to prepare for bot
  # followup
  def mark_info_completed(ride)
    update_attributes(Conversation.ride_conversation_attrs(ride))
  end

  def self.ride_conversation_attrs(ride)
    {
      user: ride.voter,
      status: :ride_created,
      ride: ride,
      from_address: ride.from_address,
      from_latitude: ride.from_latitude,
      from_longitude: ride.from_longitude,
      from_confirmed: true,
      to_address: ride.to_address,
      to_latitude: ride.to_latitude,
      to_longitude: ride.to_longitude,
      to_confirmed: true,
      pickup_at: ride.pickup_at,
      time_confirmed: true,
      additional_passengers: ride.additional_passengers,
      special_requests: ride.special_requests
    }
  end

  # create a new conversation initiated by staff
  # returns conversation if successful otherwise an error message
  def self.create_from_staff(ride_zone, user, body, timeout, attrs = {})
    from_phone = ride_zone.phone_number_normalized
    to_phone = user.phone_number_normalized
    c = Conversation.create({ride_zone: ride_zone, user: user, from_phone: from_phone,
                            to_phone: to_phone, status: :in_progress}.merge(attrs))
    sms = send_staff_sms(ride_zone, user, body, timeout)
    if sms.is_a?(String)
      # create dummy message so we know what we intended to send
      sms = OpenStruct.new(sid: 'n/a', status: 'failed', body: "(Failed to send) #{body}", from: from_phone, to: to_phone)
    end
    Message.create_from_staff(c, sms)
    c
  end

  def self.send_staff_sms(ride_zone, user, body, timeout)
    sms = begin
      TwilioService.send_message(
        { from: ride_zone.phone_number_normalized, to: user.phone_number, body: body},
        timeout)
    rescue => e
      logger.error "TWILIO ERROR #{e.message} User id #{user.id} Message #{body}"
      return "Twilio error #{e.message}"
    end
    info = "user_id: #{user.id} to: #{user.phone_number} from: #{ride_zone.phone_number_normalized}: '#{body}'"
    logger.info "TWILIO sent staff sms #{info} code: #{sms.error_code} status: #{sms.status}"
    if sms.error_code
      logger.error "TWILIO ERROR #{sms.error_code} #{info}"
      return "Communication error #{sms.error_code}"
    elsif sms.status.to_s != 'delivered'
      logger.error "TWILIO note timeout #{info}"
    end
    sms
  end

  def self.unreachable_phone_error(errormsg)
    errormsg.is_a?(String) && errormsg =~ /30003|30005|30006/
  end

  def close(username)
    if ride
      ride.cancel(username) # also closes this convo
    else
      self.status = :closed
      save!
    end
  end

  def username
    if self.user && !self.user.has_sms_name?
      self.user.name
    else
      ''
    end
  end

  def status_str
    self.status.gsub('_', ' ').titleize
  end

  def lifecycle_str
    self.lifecycle.gsub('_', ' ').titleize
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

  def block_bot_reply?
    should_block = self.status == 'help_needed' || self.ride_zone.bot_disabled
    logger.info "CONVOBOT blocking reply: status: #{self.status} disabled: #{self.ride_zone.bot_disabled}" if should_block
    should_block
  end

  def user_language
    user.language == 'unknown' ? 'en' : user.language
  end

  # returns a string with category of result
  def attempt_confirmation
    result = 'waiting_confirmation'
    if self.ride_confirmed.nil? && self.user
      body = I18n.t(:confirm_ride, locale: user_language, time: ride.pickup_in_time_zone.strftime('%l:%M %P'))
      
      sms = Conversation.send_staff_sms(ride_zone, user, body, Rails.configuration.twilio_timeout)
      if Conversation.unreachable_phone_error(sms)
        # go ahead and promote b/c we can't reach the voter
        ActiveRecord::Base.transaction do
          ride.update_attributes(status: :waiting_assignment)
          update_attributes(ride_confirmed: true)
        end
        return 'bad_phone_auto_confirm'
      end
      
      return 'twilio_error' if sms.is_a?(String) # error sending, will try again
      
      ActiveRecord::Base.transaction do
        Message.create_from_bot(self, sms)
        update_attributes(ride_confirmed: false, bot_counter: 0, status: :ride_created)
      end
      result = 'sent_confirm_request'
      
    elsif self.ride_confirmed == false && Time.now > ride.pickup_at
      # ride has not been confirmed and pickup time has passed, auto_confirm
      # go ahead and promote b/c we can't reach the voter
      ActiveRecord::Base.transaction do
        ride.update_attributes(status: :waiting_assignment) if ride.status == 'scheduled'
        update_attributes(ride_confirmed: true)
      end
      return 'no_response_auto_confirm'
    end
    result
  end

  def notify_voter_of_assignment(driver)
    if driver
      desc = driver.description
      desc += (" - %s" % driver.license_plate) unless driver.license_plate.blank?
      body = I18n.t(:driver_assigned, locale: user_language, name: driver.name, description: desc)
    else
      body = I18n.t(:driver_cleared, locale: user_language)
    end
    sms = Conversation.send_staff_sms(ride_zone, user, body, Rails.configuration.twilio_timeout)
    return if sms.is_a?(String) # todo: track state and retry?
    Message.create_from_bot(self, sms)
  end

  def self.active_statuses
    Conversation.statuses.keys - ['closed']
  end

  def voter_phone_blacklisted?
    self.reload
    self.blacklisted_phone.nil? ? false : true
  end

  def blacklist_voter_phone
    BlacklistedPhone.create!(phone: self.from_phone, conversation_id: self.id) unless BlacklistedPhone.where(phone: self.from_phone).any?
  end

  def unblacklist_voter_phone
    BlacklistedPhone.delete self.blacklisted_phone
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
    if status == 'ride_created'
      if ride_confirmed == false
        lckey = :requested_confirmation
      else
        lckey = :info_complete
      end
    elsif user.unknown_language?
      lckey = :created
    elsif user.name.blank? || user.has_sms_name?
      lckey = :have_language
    elsif !ignore_prior_ride && user.recent_complete_ride && !user.recent_complete_ride.has_unknown_destination? && from_latitude.nil?
      lckey = :have_prior_ride
    elsif from_latitude.nil? || from_longitude.nil?
      lckey = :have_name
    elsif !from_confirmed
      lckey = :have_origin
    elsif has_unknown_destination? && pickup_at.nil? && !time_confirmed
      lckey = :have_confirmed_destination
    elsif (to_latitude.nil? || to_longitude.nil?) && !has_unknown_destination?
      lckey = :have_confirmed_origin
    elsif !to_confirmed
      lckey = :have_destination
    elsif pickup_at.nil?
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

  def validate_voter_phone_not_blacklisted
    if self.new_record? && BlacklistedPhone.has_voter_phone?(self.from_phone)
      errors.add(:from_phone, 'has been blacklisted')
    end
  end
end
