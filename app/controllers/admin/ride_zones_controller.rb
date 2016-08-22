class Admin::RideZonesController < Admin::AdminApplicationController

  skip_before_action :require_admin_privileges, only: [:show, :edit, :update]
  before_action :set_ride_zone, except: [:index, :new, :create]
  before_action :require_zone_privilege

  def index
    @ride_zones = RideZone.all
  end

  def show
    @dispatchers = @ride_zone.dispatchers
    @drivers = @ride_zone.drivers

    # TODO: @drivers_on_call = User.with_role(:driver, @ride_zone).on_call
    status = params[:status]
    if status.present?
      rel = @ride_zone.conversations.order('created_at DESC')
      if rel.respond_to? status
        @conversations = rel.public_send(status)
      end
    else
      @conversations = @ride_zone.conversations.order('created_at DESC')
    end
  end

  def new
    @ride_zone = RideZone.new
  end

  def edit
    @dispatchers = User.with_role(:dispatcher, @ride_zone)
    @drivers = User.with_role(:driver, @ride_zone)
  end

  def create
    @ride_zone = RideZone.new(ride_zone_params)

    if @ride_zone.save
      redirect_to admin_ride_zones_path, notice: 'RideZone was successfully created.'
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

  def add_dispatcher
    add_role(:dispatcher)
  end

  def add_driver
    add_role(:driver)
  end

  def remove_dispatcher
    remove_role(:dispatcher)
  end

  def remove_driver
    remove_role(:driver)
  end

  private

    def remove_role(role_type)
      if params[:user_id].present?
        @user = User.find(params[:user_id])
        @user.remove_role(role_type, @ride_zone)
      end
      flash[:notice] = "Removed #{role_type}!"
      redirect_back(fallback_location: root_path)
    end

    def add_role(role_type)
      if params[:user_id].present?
        @user = User.find(params[:user_id])

        # @user.has_role? isn't working here, not sure why. using ugly check for now.
        if role_type == :driver
          already_has_role = @user.driver_ride_zone_id.present? #@user.has_role?(:driver, @ride_zone)
        elsif role_type == :dispatcher
          already_has_role = @user.dispatcher_ride_zone_id.present? #@user.has_role?(:dispatcher, @ride_zone)
        else
          already_has_role = false
        end

        unless already_has_role
          @user.add_role(role_type, @ride_zone)
          msg = "Added #{role_type.to_s}!"
        else
          msg = 'User was already a #{role_type} :/'
        end
      end
      flash[:notice] = msg
      redirect_back(fallback_location: root_path)
    end

    # Only allow a trusted parameter "white list" through.
    def ride_zone_params
      params.require(:ride_zone).permit(:name, :description, :phone_number, :short_code,
    :city, :county, :state, :zip, :country, :latitude, :longitude )
    end

end
