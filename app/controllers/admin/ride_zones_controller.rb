class Admin::RideZonesController < Admin::AdminApplicationController

  before_action :set_ride_zone, only: [:show, :edit, :update, :destroy, :add_dispatcher, :add_driver]

  def index
    @ride_zones = RideZone.all
  end

  def show
    @dispatchers = User.with_role(:dispatcher, @ride_zone)

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
      @user.add_role(:dispatcher, @ride_zone)
    end
    redirect_to :back, notice: 'Added dispatcher!'
  end

  def add_driver
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @user.add_role(:driver, @ride_zone)
    end
    redirect_to :back, notice: 'Added driver!'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ride_zone
      @ride_zone = RideZone.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ride_zone_params
      params.require(:ride_zone).permit( :slug, :name, :description, :phone_number, :short_code,
    :city, :county, :state, :zip, :country, :latitude, :longitude )
    end

end
