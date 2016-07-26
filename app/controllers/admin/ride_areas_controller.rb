class Admin::RideAreasController < Admin::AdminApplicationController
  
  before_action :set_ride_area, only: [:show, :edit, :update, :destroy]

  def index
    @ride_areas = RideArea.all
  end

  def show
  end

  def new
    @ride_area = RideArea.new
  end

  def edit
  end

  def create
    @ride_area = RideArea.new(ride_area_params)

    if @ride_area.save
      redirect_to admin_ride_areas_path, notice: 'RideArea was successfully created.'
    else
      render :new
    end
  end

  def update
    if @ride_area.update(ride_area_params)
      redirect_to @ride_area, notice: 'RideArea was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @ride_area.destroy
    redirect_to ride_areas_url, notice: 'RideArea was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ride_area
      @ride_area = RideArea.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ride_area_params
      params.require(:ride_area).permit( :slug, :name, :description, :phone_number, :short_code,
    :city, :county, :state, :zip, :country, :latitude, :longitude )
    end
    
end
