require 'securerandom'

class RidesController < ApplicationController
  include RideParams, RideZoneParams
  
  before_action :require_session, only: [:edit, :update]
  before_action :set_ride, only: [:edit, :update]
  before_action :require_ride_zone
  around_action :set_time_zone
  
  VALIDATION_PATTERN = "( CA| ca| DC| dc| FL| fl| HI| hi| IL| il| NV| nv| OH| oh| PA| pa| | TX| tx| UT| ut| WI| wi)"

  def new
    @locale = params[:locale]
    @validation_pattern = VALIDATION_PATTERN
    @ride = Ride.new
  end

  # TODO: This is similar to the code in ride_upload, they should be refactored to common methods
  def create
    if params[:locale].present?
      @locale = params[:locale]
    else
      @locale = :en
    end

    @ride = Ride.new(ride_params)

    # check for existing voter. Similar to what's in User.find_from_potential_ride, abstract?
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= User.find_by_email(params[:ride][:email])
    normalized = PhonyRails.normalize_number(params[:ride][:phone_number], default_country_code: 'US')
    # unless normalized.nil? || normalized == '+15555555555'
    if normalized.present? && normalized != User::DUMMY_PHONE_NUMBER
      @user ||= User.find_by_phone_number_normalized(normalized)
    end
    
    if @user
      existing = @user.open_ride # TODO: should this also check @user.active_ride ?
      if existing
        scheduled = existing.pickup_in_time_zone.strftime('%m/%d %l:%M %P %Z')
        @user.errors.add(:name, "match for voter #{@user.name} (#{@user.email}/#{@user.phone_number}) that already has an active ride scheduled for #{scheduled}")
        render :new and return
      end
    end

    if @ride.pickup_at.blank?
      flash[:notice] = "Please fill in scheduled date and time."
      render :new and return
    end
    @pickup_at = @ride.pickup_at

    if @ride.from_city_state.present? && @ride.from_city.blank? && @ride.from_state.blank?
      city_state_array = @ride.from_city_state.split(',')
      @ride.from_city = city_state_array[0].try(:strip)
      @ride.from_state = city_state_array[1].try(:strip)
    end

    if @ride.to_city_state.present? && @ride.to_city.blank? && @ride.to_state.blank?
      city_state_array = @ride.to_city_state.split(',')
      @ride.to_city = city_state_array[0].try(:strip)
      @ride.to_state = city_state_array[1].try(:strip)
    end

    # if ride is rolled back we want to make sure the user is too.
    ActiveRecord::Base.transaction do
      unless @user
        user_params = params.require(:ride).permit(:phone_number, :email, :name, :password)
        user_attrs = {
            name: user_params[:name],
            phone_number: user_params[:phone_number],
            ride_zone: @ride_zone,
            ride_zone_id: @ride_zone.id,
            email: user_params[:email] || User.autogenerate_email,
            password: user_params[:password] || SecureRandom.hex(8),
            city: @ride.from_city,
            state: @ride.from_state,
            locale: @locale,
            language: @locale,
            user_type: 'voter',
        }

        # TODO: better error handling
        @user = User.create(user_attrs)
        if @user.errors.any?
          flash[:notice] = "Problem creating a new user."
          render :new and return
        end
      end

      @ride.voter = @user
      @ride.from_zip = @user.zip
      @ride.status = :scheduled
      @ride.ride_zone = @ride_zone
      @ride.to_address = Ride::UNKNOWN_ADDRESS if @ride.to_address.blank?

      if @ride.save
        Conversation.create_from_ride(@ride, thanks_msg(@ride))
        UserMailer.welcome_email_voter_ride(@user, @ride).deliver_later
        render :success
      else
        @user = nil
        flash[:notice] = "Problem creating a ride."
        render :new and return
      end
    end
  end

  def edit
    @validation_pattern = VALIDATION_PATTERN
    I18n.locale = @ride.voter.locale
    @ride_zone = @ride.ride_zone
    @pickup_at = @ride.pickup_in_time_zone
  end

  def update
    I18n.locale = @ride.voter.locale
    if @ride.update(ride_params)
      render :success
      @ride.conversation.send_from_staff(thanks_msg(@ride), Rails.configuration.twilio_timeout)
      UserMailer.welcome_email_voter_ride(@ride.voter, @ride).deliver_later
    else
      render :edit
    end
  end

  private
  
  def require_session
    redirect_to '/users/sign_in' unless user_signed_in?
  end

  def require_ride_zone
    @ride_zone = @ride.ride_zone if @ride
    set_ride_zone(:ride_zone_id) unless @ride_zone
    render :need_area unless @ride_zone
  end

  def set_time_zone(&block)
    Time.use_zone(@ride_zone.time_zone, &block) if @ride_zone
  end
end
