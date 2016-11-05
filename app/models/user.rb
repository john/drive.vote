class User < ApplicationRecord
  require 'csv'
  include States

  # TODO: when geocoding is enabled
  # acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  rolify strict: true, after_add: :if_driver_remove_unassigned, after_remove: :make_unassigned

  geocoded_by :full_address do |user, results|
    if geo = results.first
      user.latitude = geo.latitude
      user.longitude = geo.longitude
      user.zip = geo.postal_code if geo.postal_code.present?
    end
  end

  after_validation :geocode, if: ->(obj){ obj.new_record? }

  # TODO: when users & ridezones are geocoded
  # def nearby_ride_zones
  # end

  VALID_ROLES = [:admin, :dispatcher, :driver, :unassigned_driver, :voter]
  VALID_STATES = {'CA' => 'California', 'DC' => 'District of Columbia', 'FL' => 'Florida', 'HI' => 'Hawaii', 'NV' => 'Nevada', 'NY' => 'New York', 'OH' => 'Ohio', 'PA' =>'Pennsylvania', 'UT' => 'Utah'}
  has_many :rides, foreign_key: :voter_id, dependent: :destroy
  has_many :conversations, foreign_key: :user_id, dependent: :destroy

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
  attr_accessor :superadmin

  serialize :start_drive_time, Tod::TimeOfDay
  serialize :end_drive_time, Tod::TimeOfDay

  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :phone_number_normalized, phony_plausible: true
  validate :permissible_user_type
  validate :permissible_zip, if: -> (obj) { obj.zip_changed? || obj.new_record? }
  validate :permissible_state, if: -> (obj) { obj.state_changed? || obj.new_record? }

  validates :email, length: { maximum: 50 }
  validates :name, length: { maximum: 50 }
  validates :phone_number, length: { maximum: 17 }
  validates :address1, length: { maximum: 100 }
  validates :address2, length: { maximum: 100 }
  validates :city, length: { maximum: 50 }
  validates :state, length: { maximum: 2 }
  validates :zip, length: { maximum: 12 }
  validates :country, length: { maximum: 50 }

  # scope that gets Users, of any/all roles, close to a particular RideZone
  scope :nearby_ride_zone, ->(rz) { near(rz.zip, GEO_NEARBY_DISTANCE) }


  def self.voters
    User.with_role(:voter, :any)
  end

  def self.non_voters(order: 'name', sort: 'ASC')
    User.where.not(id: User.with_role(:voter, :any)).order("#{order} #{sort}")
  end

  def self.users
    ids = User.with_any_role({name: :admin, resource: :any}, {name: :dispatcher, resource: :any}).pluck(:id)
    User.where(id: ids)
  end

  def self.assigned_drivers
    User.with_role(:driver, :any)
  end

  def self.unassigned_drivers
    User.with_role( :unassigned_driver, :any )
  end

  def self.all_drivers
      User.assigned_drivers + User.unassigned_drivers
    end

  def self.sms_name(phone_number)
    "#{phone_number} via sms"
  end

  def self.to_csv(options = {}, timezone = 'UTC')
    CSV.generate(options) do |csv|
      attributes = %w{name email phone_number_normalized created_at}
      csv << attributes
      all.sort{|a,b| a <=> b}.each do |driver|
        csv << attributes.map do |attr|
          if attr == 'created_at'
            driver.send(attr).in_time_zone(timezone).strftime("%Y-%m-%d %H:%M:%S %z")
          else
            driver.send(attr)
          end
        end
      end
    end
  end

  def api_json
    data = self.as_json(only: [:id, :available, :latitude, :longitude], methods: [:phone, :location_timestamp])
    data['name'] = CGI::escape_html(name || '')
    data.merge('active_ride' => self.active_ride.try(:api_json))
  end

  def is_super_admin?
    self.has_role?(:admin)
  end

  def is_zone_admin?
    RideZone.find_roles(:admin, self).present?
  end

  def is_dispatcher?
    RideZone.find_roles(:dispatcher, self).present?
  end

  def is_driver?
    RideZone.find_roles(:driver, self).present?
  end

  def is_unassigned_driver?
    RideZone.find_roles(:unassigned_driver, self).present?
  end

  def is_only_unassigned_driver?
    if RideZone.find_roles(:unassigned_driver, self).present? &&
      !self.is_super_admin? &&
      !self.is_zone_admin? &&
      !self.is_dispatcher? &&
      !self.is_driver?
      true
    else
      false
    end
  end

  def is_voter?
    RideZone.find_roles(:voter, self).present?
  end

  def role_names
    self.roles.collect do |r|
      if r.resource_id.present?
        name = "#{r.name} (#{RideZone.find(r.resource_id).name})"
      else
        name = r.name
      end
      name.gsub('_', ' ')
    end.join(', ')
  end

  def driver_ride_zone_id
    # the roles table has entries for driver with resource id = ride zone id
    driver_role = self.roles.where(name: 'driver').first
    if driver_role.blank?
      driver_role = self.roles.where(name: 'unassigned_driver').first
    end
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
    [self.address1, self.address2, self.city, self.state, self.zip, self.country].reject(&:empty?).join(', ')
  end

  def parse_city_state
    c_s_array = self.city_state.split(/ |,/).reject { |cs| cs.blank? }

    if c_s_array.size > 1
      if state = c_s_array.pop
        if STATES.keys.include?(state.strip.upcase.to_sym)
          self.city = c_s_array.join(' ').titlecase
          self.state = state.strip.upcase
        end
      end
    elsif c_s_array.size == 1
      if STATES.keys.include?(c_s_array[0].strip.upcase.to_sym)
        self.state = c_s_array[0].strip.upcase
      end
    end
  end

  def mark_info_completed
    self.language = :en if language == 'unknown'
    self.name = self.name.gsub(/ via sms/, '') if has_sms_name?
    save!
  end

  def qa_clear
    convos = Conversation.where(user_id: self.id)
    convos.each do |convo|
      convo.ride.destroy if convo.ride
      convo.destroy
    end
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
    if self.is_driver? && added_role.name != 'unassigned_driver'
      self.remove_role(:unassigned_driver)
    end
  end

  def make_unassigned(removed_role)
    if removed_role.name == 'driver' && !self.is_unassigned_driver?
      self.add_role(:unassigned_driver, RideZone.find(removed_role.resource_id))
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
    # don't create super admins
    if self.ride_zone.blank? && self.user_type == 'admin'
      raise "Bad role, model."
    end

    if self.ride_zone.blank? && self.ride_zone_id.present?
      rz = RideZone.find( self.ride_zone_id )
      self.ride_zone = rz
    end

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
    return if has_sms_name? || @@sim_mode
    if self.has_role?('driver', :any)
      UserMailer.welcome_email_driver(self).deliver_later
    end
  end
end
