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
    @user = current_user
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
        redirect_to '/users/sign_in?locale=' + @user.locale and return
      end
    end

    # create user if not found
    rp = ride_params
    @ride = Ride.new(rp)

    if @ride.pickup_at.blank?
      if Chronic.parse(params[:pickup_day]) && Chronic.parse(params[:pickup_time])
        from_date_time = Chronic.parse( [params[:pickup_day], params[:pickup_time]].join(' ') )
        @ride.pickup_at =  from_date_time
      else
        @ride.errors.add(:pickup_at, :invalid)
        flash[:notice] = "Please fill in scheduled date and time."
        redirect_back(fallback_location: root_path) and return
      end
    end

    unless @user
      user_params = params.require(:ride).permit(:phone_number, :email, :name, :password)
      attrs = {
          name: user_params[:name],
          phone_number: user_params[:phone_number],
          ride_zone: @ride_zone,
          email: user_params[:email],
          password: user_params[:password] || SecureRandom.hex(8),
          locale: @locale,
          user_type: :voter,
      }
      # todo: better error handling
      @user = User.create(attrs)
      if @user.errors.any?
        flash[:notice] = "Problem creating a new user."
        redirect_back(fallback_location: root_path) and return
      end
    end

    @ride.voter = @user
    @ride.status = :scheduled
    @ride.ride_zone = @ride_zone

    if @ride.save
      Conversation.create_from_staff(@ride_zone, @user, thanks_msg, Rails.configuration.twilio_timeout,
                                     {status: :ride_created, ride: @ride})
      UserMailer.welcome_email_voter_ride(@user, @ride).deliver_later
      render :success
    else
      flash[:notice] = "Problem creating a ride."
      redirect_back(fallback_location: root_path) and return
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
    I18n.t(:thanks_for_requesting, locale: (@ride.voter.locale ||= 'en'), time: @ride.pickup_at.strftime('%m/%d %l:%M %P'), email: 'hello@drive.vote')
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
