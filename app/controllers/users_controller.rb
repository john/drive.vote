class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]

  skip_before_filter :go_complete_profile, :only => [:create, :edit, :update]
  

  # GET /users/1
  # GET /users/1.json
  def show
    # add error handling
    # @marker_hash = Gmaps4rails.build_markers([@user]) do |user, marker|
    #   marker.lat user.latitude
    #   marker.lng user.longitude
    # end
    
    # query for other nearby users. Don't run once they have a confirmed ride.
    # @nearby_drivers = User.drivers.near( [@user.latitude, @user.longitude], 20 ).size
    # @nearby_riders = User.riders.near( [@user.latitude, @user.longitude], 20 )
    #
    # @google_api_key = 'AIzaSyDefFnLJQKoz1OQGjaqaJPHMISVcnXZNPc'
    
    # FAIL (gem can't be installed?)
    # client = GoogleCivicInfo::Client.new(:api_key => @google_api_key)
    # @civic_info = client.lookup( @user.full_street_address )
    
    # FAIL:
    #client = CivicAide::Client.new(@google_api_key)
    #@civic_info = client.elections.all #.at( @user.full_street_address )
    
    # http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CivicinfoV2/CivicInfoService#query_voter_info-instance_method
    
    # require 'google/apis/civicinfo_v2'
    # c = Google::Apis::CivicinfoV2::CivicInfoService.new
    # c.key = 'AIzaSyDefFnLJQKoz1OQGjaqaJPHMISVcnXZNPc'
    #
    # # recent upcoming elections:
    # @elections = c.query_election
    #
    # @elections.elections.
    # @voter_info = c.query_voter_info('330 Cabrillo St., San Francisco, CA 94118', election_id: 4224)
    
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    # user_type is put in to the session in OmniauthCallbacksController
    @type = session['user_type']
    
    # This key is tied to john@fnnny.com, needs the Google Places Web API enabled
    @google_api_key = 'AIzaSyBaEubvpgWxx7oxKiDgnp5sWF_qggJeCQg'
    
    @time_hash = {'7:00am'=>'7:00am', '8:00am'=>'8:00am', '9:00am'=>'9:00am',
      '10:00am'=>'10:00am', '11:00am'=>'11:00am', '12:00pm'=>'12:00pm',
      '1:00pm'=>'1:00pm', '2:00pm'=>'2:00pm', '3:00pm'=>'3:00pm', '4:00pm'=>'4:00pm',
      '5:00pm'=>'5:00pm', '6:00pm'=>'6:00pm', '7:00pm'=>'7:00pm'}
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    session.delete(:user_type)
    new_user = @user.phone_number.blank?
    
    respond_to do |format|
      if @user.update(user_params)
        
        # different notice if the user was just created
        notice = (new_user) ? 'Welcome to Drive the Vote!' : 'User was successfully updated.'
        
        format.html { redirect_to @user, notice: notice }
        format.json { render :show, status: :ok, location: @user }
      else
        @type = session['user_type']
        
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end



    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      # params.fetch(:user, {})
      params.require(:user).permit(:name, :user_type, :email, :phone_number, :image_url,
      :primary_language, :languages_spoken, :car_make_and_model, :max_passengers,
      :start_drive_time, :end_drive_time, :description, :special_requests,
      :address1, :address2, :city, :state, :zip, :country, :latitude, :longitude,
      :accepted_tos, :email_list, :agree_to_background_check
      )
    end
end
