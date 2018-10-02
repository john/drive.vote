class Admin::RideZonesController < Admin::AdminApplicationController
  include RideZoneParams
  include AccessMethods

  before_action :set_ride_zone, except: [:index, :new, :create]
  before_action :require_zone_admin, except: [:index] # handled at the method level
  before_action :require_admin_privileges, only: [:new, :create] # only super admins

  def index
    if current_user.present?
      if current_user.has_role?(:admin)
        @ride_zones = RideZone.all
      elsif current_user.is_zone_admin?
        @ride_zones = RideZone.with_user_in_role(current_user, :admin)
      else
        redirect_to '/404.html'
      end
    else
      redirect_to '/404.html'
    end
  end

  def show
    respond_to do |format|
      format.html do
        @dispatchers = @ride_zone.dispatchers
        @drivers = @ride_zone.drivers
      end
      
      format.csv do
        @rides = Ride.where(ride_zone_id: @ride_zone.id, status: 1)
        send_data @rides.to_csv, filename: "#{@ride_zone.slug}-rides-#{Date.today}.csv"
      end
    end
  end

  def new
    @ride_zone = RideZone.new
  end

  def edit
    setup_edit
  end

  def setup_edit
    @zone_dispatchers = @ride_zone.dispatchers
    @zone_drivers = @ride_zone.drivers
    @zone_unassigned_drivers = @ride_zone.unassigned_drivers
    @zone_admins = @ride_zone.admins

    # TODO: scope to nearby when adding proximity
    @local_users = User.non_voters
  end

  def create
    @ride_zone = RideZone.new(ride_zone_params)

    if @ride_zone.save
      redirect_to admin_ride_zones_path, notice: "RideZone was successfully created."
    else
      render :new
    end
  end

  def update
    if @ride_zone.update(ride_zone_params)
      redirect_to [:admin, @ride_zone], notice: 'RideZone was successfully updated.'
    else
      setup_edit
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
        @msg = "Added #{role_type.to_s}!"
      else
        @msg = "User is already a #{role_type} elsewhere."
      end
    else
      @msg = "I can't really do anything with that."
    end

    flash[:notice] = @msg
    redirect_to edit_admin_ride_zone_url(@ride_zone), notice: @msg
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
      else
        driver.remove_role(:driver, @ride_zone)
      end
    else
      msg = "I can't really do anything with that."
    end

    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end

end
