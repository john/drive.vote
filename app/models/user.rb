class User < ApplicationRecord
  include HasPartyAffiliation

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  rolify

  enum language: { unknown: 0, english: 1, spanish: 2 }, _suffix: true

  after_create :add_rolify_role
  after_create :send_welcome_email

  # scope :admins, -> { where(user_type: :admin) }
  # scope :dispatchers, -> { where(user_type: :dispatcher) }
  # scope :drivers, -> { where(user_type: :driver) }
  # scope :riders, -> { where(user_type: :rider) }

  attr_accessor :city_state
  attr_accessor :user_type
  # attr_accessor :role_ids

  serialize :start_drive_time, Tod::TimeOfDay
  serialize :end_drive_time, Tod::TimeOfDay

  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'

  # google api key, should work for all enabled apis, including maps & civic info:
  # AIzaSyDefFnLJQKoz1OQGjaqaJPHMISVcnXZNPc
  # https://console.developers.google.com/apis/credentials/wizard?api=maps_backend&project=phonic-client-135123
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :phone_number_normalized, phony_plausible: true

  def is_admin?
    #todo: make this rolify-based
    true
  end

  def driver_ride_zone_id
    # the roles table has entries for driver with resource id = ride zone id
    driver_role = self.roles.where(name: 'driver').first
    driver_role.try(:resource_id)
  end

  def full_street_address
    [self.address1, self.address2, self.city, self.state, self.zip, self.country].compact.join(', ')
  end

  def has_required_fields?
    !!(self.email? && self.name? && self.phone_number? && self.city? && self.state? && self.zip)
  end

  def missing_required_fields?
    !has_required_fields?
  end

  private

  def add_rolify_role
    if self.user_type.present?
      self.add_role self.user_type
    end
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

end
