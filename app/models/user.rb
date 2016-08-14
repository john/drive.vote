class User < ApplicationRecord

  # TODO: when geocoding is enabled
  # acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  rolify after_add: :if_driver_remove_unassigned, after_remove: :make_unassigned

  # TODO: Specs need to be mocked before this is enabled
  # geocoded_by :full_address
  # after_create :geocode

  def is_a_driver?
    RideZone.find_roles(:driver, self).present?
  end

  # TODO: when users & ridezones are geocoded
  # def nearby_ride_zones
  # end

  VALID_ROLES = [:admin, :dispatcher, :driver, :unassigned_driver, :voter]

  enum language: { unknown: 0, english: 1, spanish: 2 }, _suffix: true

  before_save :check_location_updated
  after_create :add_rolify_role
  after_create :send_welcome_email
  after_create :notify_creation
  around_save :notify_update

  attr_accessor :city_state
  attr_accessor :user_type, :ride_zone # set transiently for user creation

  serialize :start_drive_time, Tod::TimeOfDay
  serialize :end_drive_time, Tod::TimeOfDay

  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'

  # google api key, should work for all enabled apis, including maps & civic info:
  # AIzaSyDefFnLJQKoz1OQGjaqaJPHMISVcnXZNPc
  # https://console.developers.google.com/apis/credentials/wizard?api=maps_backend&project=phonic-client-135123
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :phone_number_normalized, phony_plausible: true
  validate :permissible_user_type
  validate :permissible_zip

  def api_json
    data = self.as_json(only: [:id, :name, :available, :latitude, :longitude], methods: [:phone, :location_timestamp])
    data.merge('active_ride' => self.active_ride.try(:api_json))
  end

  def driver_ride_zone_id
    # the roles table has entries for driver with resource id = ride zone id
    driver_role = self.roles.where(name: 'driver').first
    driver_role.try(:resource_id)
  end

  def dispatcher_ride_zone_id
    dispatcher_role = self.roles.where(name: 'dispatcher').first
    dispatcher_role.try(:resource_id)
  end

  def active_ride
    Ride.where(driver_id: self.id).or(Ride.where(voter_id: self.id)).where(status: Ride.active_statuses).first
  end

  def full_street_address
    [self.address1, self.address2, self.city, self.state, self.zip, self.country].compact.join(', ')
  end

  def location_timestamp
    self.location_updated_at.try(:to_i)
  end

  def self.sms_name(phone_number)
    "#{phone_number} via sms"
  end

  def has_sms_name?
    self.name == User.sms_name(self.phone_number)
  end

  def phone
    self.phone_number_normalized.try(:phony_formatted, normalize: :US, spaces: '-')
  end

  def has_required_fields?
    !!(self.email? && self.name? && self.phone_number? && self.city? && self.state? && self.zip)
  end

  def missing_required_fields?
    !has_required_fields?
  end


  private

  def if_driver_remove_unassigned(added_role)
    if self.is_a_driver?
      self.remove_role(:unassigned_driver)
    end
  end

  def make_unassigned(removed_role)
    if !self.is_a_driver? && removed_role.name == 'driver'
      self.add_role(:unassigned_driver)
    end
  end

  def full_address
    [self.address1, self.address2, self.city, self.state, self.zip, self.country].compact.join(', ')
  end

  # user_type is used to hold the role before it's assigned. make sure it's legit.
  def permissible_user_type
    if self.user_type.present?
      if User::VALID_ROLES.include?(self.user_type.to_sym)
        true
      else
        errors.add(:role, "not allowed")
      end
    else
      true
    end
  end

  def permissible_zip
    if self.zip.blank?
      true #no zip is allowed
    else
      if zip_hash = ZipCodes.identify( self.zip )
        unless %w(fl oh pa nc mi ga).include?( zip_hash[:state_code].downcase )
          errors.add(:zip, "isn't in a supported state.")
        end
      else
        errors.add(:zip, "couldn't be parsed")
      end
    end
  end

  def notify_creation
    # these two attributes are only present on creation
    self.ride_zone.event(:new_driver, self, :driver) if self.user_type == 'driver' && self.ride_zone
  end

  def notify_update
    was_new = new_record?
    yield
    driver_rz = driver_ride_zone_id
    RideZone.find(driver_rz).event(:driver_changed, self, :driver) if !was_new && driver_rz
  end

  def add_rolify_role
    if self.user_type.present?
      self.add_role self.user_type, self.ride_zone
    end
  end

  def check_location_updated
    if latitude_changed? || longitude_changed?
      self.location_updated_at = Time.now
    end
  end

  def send_welcome_email
    return if has_sms_name?
    if self.has_role? 'voter', :any
      UserMailer.welcome_email_voter(self).deliver_later
    elsif self.has_role? 'driver', :any
      UserMailer.welcome_email_driver(self).deliver_later
    end
  end
end
