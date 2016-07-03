class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
  
  enum user_type: [:admin, :driver, :rider, :dunno]
  serialize :start_drive_time, Tod::TimeOfDay
  serialize :end_drive_time, Tod::TimeOfDay
  
  scope :riders, -> { where(user_type: :rider) }
  scope :drivers, -> { where(user_type: :driver) }
  
  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'
  
  geocoded_by :full_street_address
  after_validation :geocode
  
  # google api key, should work for all enabled apis, including maps & civic info:
  # AIzaSyDefFnLJQKoz1OQGjaqaJPHMISVcnXZNPc
  # https://console.developers.google.com/apis/credentials/wizard?api=maps_backend&project=phonic-client-135123
    
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :phone_number_normalized, phony_plausible: true
  
  # validates :accepted_tos, :acceptance => true
  # validates :agree_to_background_check, :acceptance => true
  # validates_presence_of :state
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image_url = auth.info.image # assuming the user model has an image
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
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
  
end
