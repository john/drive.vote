class Admin::RidesController < Admin::AdminApplicationController
  include RideParams

  before_action :set_ride, only: [:show, :edit, :update, :destroy]
  around_action :set_time_zone, only: [:show, :edit, :update]

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
    @ride.from_city_state = [@ride.from_city, @ride.from_state].reject {|s| s.blank?}.compact.join(', ')
    @ride.to_city_state = [@ride.to_city, @ride.to_state].reject {|s| s.blank?}.compact.join(', ')
  end

  # TODO: there's a similar rides_controller in /admin, which is bad. is this method used? there's a spec for it.
  # POST /rides
  def create
    @ride = Ride.new(ride_params)

    if @ride.save
      @ride.conversation = Conversation.find(params[:conversation_id]) if params[:conversation_id]
      redirect_to [:admin, @ride], notice: 'Ride was successfully created.', status: :see_other
    else
      render :new
    end
  end

  # PATCH/PUT /rides/1
  def update
    attrs = ride_params
    attrs[:from_city], attrs[:from_state] = parse_city_state(attrs[:from_city_state])
    attrs[:to_city], attrs[:to_state] = parse_city_state(attrs[:to_city_state])

    if @ride.update(attrs)
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

  def set_time_zone(&block)
    Time.use_zone(@ride.ride_zone.time_zone, &block) if @ride && @ride.ride_zone
  end

  def parse_city_state(city_state)
    c_s_array = city_state.split(/ |,/).reject { |cs| cs.strip.blank? }
    if c_s_array.size > 1
      state = c_s_array.pop
      return c_s_array.join(' ').titlecase, state
    elsif c_s_array.size == 1
      return '', c_s_array[0] if c_s_array[0].length == 2
      return c_s_array[0], ''
    end
    return '', ''
  end
end
