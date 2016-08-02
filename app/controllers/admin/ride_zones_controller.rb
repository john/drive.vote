class Admin::RideZonesController < Admin::AdminApplicationController
  
  before_action :set_ride_zone, only: [:show, :edit, :update, :destroy]

  def index
    @ride_zones = RideZone.all
  end

  def show
    status = params[:status]
    @messages = case status
    when 'closed'
      @ride_zone.messages.order('created_at DESC').closed
    when 'inprogress'
      @ride_zone.messages.order('created_at DESC').inprogress
    when 'unassigned'
      @ride_zone.messages.order('created_at DESC').unassigned
    else
      @ride_zone.messages.order('created_at DESC')
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
