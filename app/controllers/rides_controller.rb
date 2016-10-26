require 'securerandom'

class RidesController < ApplicationController
  include RideParams, RideZoneParams
  before_action :require_session, only: [:edit, :update]
  before_action :set_ride, only: [:edit, :update]
  before_action :require_ride_zone
  around_action :set_time_zone

  def new
    @locale = params[:locale]
    @ride = Ride.new
    @ride.pickup_at = @ride_zone.current_time
  end

  def create
    @locale = params[:locale] || :en

    # check for existing voter
    normalized = PhonyRails.normalize_number(params[:ride][:phone_number], default_country_code: 'US')
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= User.find_by_phone_number_normalized(normalized)
    @user ||= User.find_by_email(params[:ride][:email])
    if @user
      existing = @user.open_ride
      if existing
        # after sign-in voters are redirected to edit their existing open ride
        flash[:notify] = t(:sign_in_to_edit)
        redirect_to "/users/sign_in?locale=#{locale}" and return
      end
    end

    # create user if not found
    # rp = ride_params
    @ride = Ride.new(ride_params)

    if @ride.pickup_at.blank?
      flash[:notice] = "Please fill in scheduled date and time."
      redirect_back(fallback_location: root_path) and return
    end

    if @ride.city_state.present? && @ride.from_city.blank? && @ride.from_state.blank?
      city_state_array = @ride.city_state.split(',')
      @ride.from_city = city_state_array[0].try(:strip)
      @ride.from_state = city_state_array[1].try(:strip)
    end

    unless @user
      user_params = params.require(:ride).permit(:phone_number, :email, :name, :password)
      user_attrs = {
          name: user_params[:name],
          phone_number: user_params[:phone_number],
          ride_zone: @ride_zone,
          ride_zone_id: @ride_zone.id,
          email: user_params[:email],
          password: user_params[:password] || SecureRandom.hex(8),
          city: @ride.from_city,
          state: @ride.from_state,
          locale: @locale,
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

    if @ride.save
      Conversation.create_from_staff(@ride_zone, @user, thanks_msg, Rails.configuration.twilio_timeout,
                                     {status: :ride_created, ride: @ride})
      UserMailer.welcome_email_voter_ride(@user, @ride).deliver_later
      render :success
    else
      flash[:notice] = "Problem creating a ride."
      # redirect_back(fallback_location: root_path) and return
      render :new and return
    end
  end

  def edit
    I18n.locale = @ride.voter.locale
    @ride_zone = @ride.ride_zone
  end

  def update
    I18n.locale = @ride.voter.locale
    if @ride.update(ride_params)
      render :success
      @ride.conversation.send_from_staff(thanks_msg, Rails.configuration.twilio_timeout)
      UserMailer.welcome_email_voter_ride(@ride.voter, @ride).deliver_later
    else
      render :edit
    end
  end

  private
  def thanks_msg
    I18n.t(:thanks_for_requesting, locale: (@ride.voter.locale ||= 'en'), time: @ride.pickup_at.strftime('%m/%d %l:%M %P'), email: @ride.ride_zone.email)
  end

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
