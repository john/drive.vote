class Admin::RideZonesController < Admin::AdminApplicationController
  include RideZoneParams

  before_action :set_ride_zone, except: [:index, :new, :create]
  before_action :require_zone_admin, except: [:index] # handled at the method level
  before_action :require_admin_privileges, only: [:new, :create] # only super admins

  def index
    if current_user.present?
      if current_user.has_role?(:admin)
        @ride_zones = RideZone.all
      elsif current_user.is_zone_admin?
        @ride_zones = RideZone.with_role(:admin, current_user)
      else
        redirect_to '/404.html'
      end
    else
      redirect_to '/404.html'
    end
  end

  def show
    @dispatchers = @ride_zone.dispatchers
    @drivers = @ride_zone.drivers
  end

  def drivers
    @drivers = @ride_zone.drivers
    @unassigned_drivers = @ride_zone.unassigned_drivers
  end

  def new
    @ride_zone = RideZone.new
  end

  def edit
    @zone_dispatchers = @ride_zone.dispatchers
    @zone_drivers = @ride_zone.drivers
    @zone_admins = User.with_role(:admin, @ride_zone) #@ride_zone.admins

    # TODO: scope to nearby when adding proximity
    @local_users = User.where.not(id: User.with_role(:voter)) #User.all
  end

  def create
    @ride_zone = RideZone.new(ride_zone_params)

    if ride_zone_params.has_key?(:admin_name) &&
        ride_zone_params.has_key?(:admin_email) &&
        ride_zone_params.has_key?(:admin_phone_number) &&
        ride_zone_params.has_key?(:admin_password)

      if @admin_user = User.find_by_email( ride_zone_params[:admin_email] )
        user_creation_flash = ". User already exists, promoting to RZ admin."
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
        driver.add_role(:driver, @ride_zone)
        driver.remove_role(:unassigned_driver, @ride_zone)
      else
        driver.add_role(:unassigned_driver, @ride_zone)
        driver.remove_role(:driver, @ride_zone)
      end
    else
      msg = "I can't really do anything with that."
    end

    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end

end
