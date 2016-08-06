class Admin::RideZonesController < Admin::AdminApplicationController

  skip_before_action :require_admin_privileges, only: [:show, :edit, :update]
  before_action :set_ride_zone, except: [:index, :new, :create]
  before_action :require_zone_privilege

  def index
    @ride_zones = RideZone.all
  end

  def show
    @dispatchers = @ride_zone.dispatchers #User.with_role(:dispatcher, @ride_zone)
    @drivers = @ride_zone.drivers #User.with_role(:driver, @ride_zone)

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
      redirect_to @ride_zone, notice: 'RideZone was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @ride_zone.destroy
    redirect_to ride_zones_url, notice: 'RideZone was successfully destroyed.'
  end

  def add_dispatcher
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      unless @user.has_role?(:dispatcher, @ride_zone)
        @user.add_role(:dispatcher, @ride_zone)
        msg = 'Added dispatcher!'
      else
        msg = 'User was already a dispatcher :/'
      end
    end
    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end

  def add_driver
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      unless @user.has_role?(:driver, @ride_zone)
        @user.add_role(:driver, @ride_zone)
        msg = 'Added driver!'
      else
        msg = 'User was already a driver :/'
      end
    end
    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end

  def remove_dispatcher
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @user.remove_role(:dispatcher, @ride_zone)
    end
    redirect_back(fallback_location: root_path, notice: 'Removed dispatcher!')
  end

  def remove_driver
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @user.remove_role(:driver, @ride_zone)
    end
    redirect_back(fallback_location: root_path, notice: 'Removed driver!')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ride_zone
      @ride_zone = RideZone.find(params[:id])
    end

    def require_zone_privilege
      unless user_signed_in? && ( current_user.has_role?(:admin) || current_user.has_role?(:dispatcher, @ride_zone) )
        redirect_to '/404.html'
      end
    end

    # Only allow a trusted parameter "white list" through.
    def ride_zone_params
      params.require(:ride_zone).permit( :slug, :name, :description, :phone_number, :short_code,
    :city, :county, :state, :zip, :country, :latitude, :longitude )
    end

end
