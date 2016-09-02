class Admin::RideZonesController < Admin::AdminApplicationController
  include RideZoneParams

  skip_before_action :require_admin_privileges, only: [:show, :edit, :update]
  before_action :set_ride_zone, except: [:index, :new, :create]
  before_action :require_zone_privilege

  def index
    @ride_zones = RideZone.all
  end

  def show
    @dispatchers = @ride_zone.dispatchers
    @drivers = @ride_zone.drivers

    # # TODO: @drivers_on_call = User.with_role(:driver, @ride_zone).on_call
    # status = params[:status]
    # if status.present?
    #   rel = @ride_zone.conversations.order('created_at DESC')
    #   if rel.respond_to? status
    #     @conversations = rel.public_send(status)
    #   end
    # else
    #   @conversations = @ride_zone.conversations.order('created_at DESC')
    # end
  end

  def drivers
    @drivers = @ride_zone.drivers
    @unassigned_drivers = @ride_zone.unassigned_drivers
  end

  def new
    @ride_zone = RideZone.new
  end

  def edit
    @dispatchers = @ride_zone.dispatchers
    @drivers = @ride_zone.drivers
    @admins = User.with_role(:admin, @ride_zone) #@ride_zone.admins
    @local_users = User.all
  end

  def create
    @ride_zone = RideZone.new(ride_zone_params)

    if ride_zone_params.has_key?(:admin_name) &&
        ride_zone_params.has_key?(:admin_email) &&
        ride_zone_params.has_key?(:admin_phone_number) &&
        ride_zone_params.has_key?(:admin_password)

      if @admin_user = User.find_by_email( ride_zone_params[:admin_email] )
        user_creation_flash = ". User already existed, promoting to RZ admin."
      else
        @admin_user = User.create!({
          name: ride_zone_params[:admin_name],
          email: ride_zone_params[:admin_email],
          phone_number: ride_zone_params[:admin_phone_number],
          password: ride_zone_params[:admin_password],
          locale: I18n.locale
        })
        user_creation_flash = "; user created and made RZ admin."
      end
    end

    if @ride_zone.save
      @admin_user.add_role(:admin, @ride_zone) if @admin_user.present?
      redirect_to admin_ride_zones_path, notice: "RideZone was successfully created #{user_creation_flash}"
    else
      render :new
    end
  end

  def update
    if @ride_zone.update(ride_zone_params)
      redirect_to [:admin, @ride_zone], notice: 'RideZone was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @ride_zone.destroy
    redirect_to admin_ride_zones_url, notice: 'RideZone was successfully destroyed.'
  end

  def add_role
    if params[:user_id].present? && role_type = params[:role].to_sym
      @user = User.find(params[:user_id])

      if role_type == :driver
        already_has_role = @user.has_role?(:driver, @ride_zone)
      elsif role_type == :dispatcher
        already_has_role = @user.has_role?(:dispatcher, @ride_zone)
      elsif role_type == :admin
        already_has_role = @user.has_role?(:admin, @ride_zone)
      else
        already_has_role = false
      end

      unless already_has_role
        @user.add_role(role_type, @ride_zone)
        msg = "Added #{role_type.to_s}!"
      else
        msg = 'User was already a #{role_type} :/'
      end
    else
      msg = "I can't really do anything with that."
    end

    flash[:notice] = msg
    redirect_back(fallback_location: root_path)

  end

  def remove_role
    if params[:user_id].present? && role_type = params[:role].to_sym
      @user = User.find(params[:user_id])
      @user.remove_role(role_type, @ride_zone)
      msg = "Removed #{role_type}!"
    else
      msg = "I can't really do anything with that."
    end

    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end

  def change_role
    if params[:driver].present?
      driver = User.find(params[:driver])

      if params[:to_role] == 'driver'
        logger.debug "-------------------> MAKE DRIVER"
        driver.add_role(:driver, @ride_zone)
        driver.remove_role(:unassigned_driver, @ride_zone)
      else
        logger.debug "-------------------> params[:to_role]: #{params[:to_role]}"

        logger.debug "-------------------> MAKE UNASSIGNED"
        driver.add_role(:unassigned_driver, @ride_zone)
        driver.remove_role(:driver, @ride_zone)
      end
    else
      msg = "I can't really do anything with that."
    end

    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end

  private

    # Only allow a trusted parameter "white list" through.
    def ride_zone_params
      params.require(:ride_zone).permit(:name, :description, :phone_number, :short_code, :city,
                                        :county, :state, :zip, :country, :latitude, :longitude, :slug,
                                        :admin_name, :admin_email, :admin_phone_number, :admin_password)
    end

end
