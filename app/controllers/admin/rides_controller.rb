class Admin::RidesController < Admin::AdminApplicationController
  include RideParams

  before_action :set_ride, only: [:show, :edit, :update, :destroy]

  RIDE_SEARCH = "(lower(rides.name) LIKE ?) OR (lower(rides.from_address) LIKE ?) OR (lower(rides.from_city) LIKE ?) OR (lower(rides.from_state) LIKE ?) OR (lower(rides.special_requests) LIKE ?)".freeze

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    if params[:q].present?
      @q = params[:q].downcase
      @rides = Ride.where(RIDE_SEARCH, "%#{@q}%", "%#{@q}%", "%#{@q}%", "%#{@q}%", "%#{@q}%").paginate(page: page, per_page: per_page)
    else
      @rides = Ride.paginate(page: page, per_page: per_page).order("created_at ASC")
    end
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
      @ride.conversation = Conversation.find(params[:conversation_id]) if params[:conversation_id]
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
