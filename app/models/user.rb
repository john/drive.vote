class User < ApplicationRecord

  # TODO: when geocoding is enabled
  # acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  rolify after_add: :if_driver_remove_unassigned, after_remove: :make_unassigned

  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.new_record? }

  def is_a_driver?
    RideZone.find_roles(:driver, self).present?
  end

  # TODO: when users & ridezones are geocoded
  # def nearby_ride_zones
  # end

  VALID_ROLES = [:admin, :dispatcher, :driver, :unassigned_driver, :voter]
  VALID_STATES = {'FL' => 'Florida', 'GA' => 'Georgia', 'NV' => 'Nevada', 'NC' => 'North Carolina', 'OH' => 'Ohio',  'PA' =>'Pennsylvania', 'WI' => 'Wisconsin'}
  has_many :rides, foreign_key: :voter_id

  enum language: { unknown: 0, en: 1, es: 2 }, _suffix: true

  before_save :check_location_updated
  after_create :add_rolify_role
  after_create :send_welcome_email
  after_create :notify_creation
  around_save :notify_update

  cattr_accessor :sim_mode

  attr_accessor :city_state
  attr_accessor :user_type
  attr_accessor :ride_zone # set transiently for user creation
  attr_accessor :ride_zone_id

  serialize :start_drive_time, Tod::TimeOfDay
  serialize :end_drive_time, Tod::TimeOfDay

  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :phone_number_normalized, phony_plausible: true
  validate :permissible_user_type
  validate :permissible_zip, if: -> (obj) { obj.zip_changed? || obj.new_record? }
  validate :permissible_state, if: -> (obj) { obj.state_changed? || obj.new_record? }

  # scope that gets Users, of any/all roles, close to a particular RideZone
  scope :nearby_ride_zone, ->(rz) { near(rz.zip, GEO_NEARBY_DISTANCE) }

  def self.non_voters
    User.where.not(id: User.with_role(:voter))
  end

  def self.sms_name(phone_number)
    "#{phone_number} via sms"
  end

  def api_json
    data = self.as_json(only: [:id, :name, :available, :latitude, :longitude], methods: [:phone, :location_timestamp])
    data.merge('active_ride' => self.active_ride.try(:api_json))
  end

  def is_super_admin?
    self.has_role?(:admin)
  end

  def driver_ride_zone_id
    # the roles table has entries for driver with resource id = ride zone id
    driver_role = self.roles.where(name: 'driver').first
    driver_role.try(:resource_id)
  end

  def voter_ride_zone_id
    voter_role = self.roles.where(name: 'voter').first
    voter_role.try(:resource_id)
  end

  def active_ride
    Ride.where(driver_id: self.id).or(Ride.where(voter_id: self.id)).where(status: Ride.active_statuses).first
  end

  def open_ride
    Ride.where(driver_id: self.id).or(Ride.where(voter_id: self.id)).where.not(status: :complete).first
  end

  def recent_complete_ride
    self.rides.merge(Ride.completed).order('updated_at desc').first
  end

  def full_street_address
    [self.address1, self.address2, self.city, self.state, self.zip, self.country].compact.join(', ')
  end

  def location_timestamp
    self.location_updated_at.try(:to_i)
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
    if removed_role.name == 'driver'
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
    elsif self.has_role? :admin
      true # admins might live anywhere
    else
      if zip_hash = ZipCodes.identify( self.zip )
        unless User::VALID_STATES.keys.include?( zip_hash[:state_code].to_s.upcase )
          errors.add(:zip, "isn't in a supported state.")
        end
      else
        errors.add(:zip, "couldn't be parsed")
      end
    end
  end

  def permissible_state
    if self.has_role? :admin
      true # admins might live anywhere
    elsif self.state.blank?
      true # no state is allowed
    else
      if User::VALID_STATES.keys.include?( self.state.upcase.strip )
        true
      else
        errors.add(:state, "isn't a supported state.")
      end
    end
  end

  def notify_creation
    rz_id = self.ride_zone_id || self.ride_zone.try(:id)
    RideZone.event(rz_id, :new_driver, self, :driver) if self.user_type == 'driver' && rz_id
  end

  def notify_update
    was_new = new_record?
    yield
    driver_rz = driver_ride_zone_id
    RideZone.event(driver_rz, :driver_changed, self, :driver) if !was_new && driver_rz
  end

  def add_rolify_role
    if self.user_type.present?
      self.add_role self.user_type, self.ride_zone
    end

    if self.ride_zone_id.present?
      if ride_zone = RideZone.find(self.ride_zone_id)
        self.add_role :unassigned_driver, ride_zone
      end
    end
  end

  def check_location_updated
    if latitude_changed? || longitude_changed?
      self.location_updated_at = Time.now
    end
  end

  def send_welcome_email
    return if has_sms_name? || @@sim_mode
    if self.has_role? 'driver', :any
      UserMailer.welcome_email_driver(self).deliver_later
    end
  end
end
