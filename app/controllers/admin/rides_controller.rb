class Admin::RidesController < Admin::AdminApplicationController
  include RideParams

  before_action :set_ride, only: [:show, :edit, :update, :destroy]

  # GET /rides
  def index
    @rides = Ride.all
  end

  # GET /rides/1
  def show
  end

  # GET /rides/new
  def new
    @ride = Ride.new
  end

  # GET /rides/1/edit
  def edit
  end

  # POST /rides
  def create
    @ride = Ride.new(ride_params)

    if @ride.save
      redirect_to [:admin, @ride], notice: 'Ride was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /rides/1
  def update
    if @ride.update(ride_params)
      redirect_to [:admin, @ride], notice: 'Ride was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /rides/1
  def destroy
    @ride.destroy
    redirect_to admin_rides_url, notice: 'Ride was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ride
      @ride = Ride.find(params[:id])
    end
end
