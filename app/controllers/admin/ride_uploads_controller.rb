class Admin::RideUploadsController < Admin::AdminApplicationController
  before_action :set_ride_upload, only: [:show, :edit, :update, :schedule, :destroy]
  before_action :set_ride_zone, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  # GET /ride_uploads
  def index
    @ride_uploads = RideUpload.where( ride_zone_id: @ride_zone.id )
  end

  # GET /admin/ride_zones/ca-25/ride_uploads/
  def show
    @failed_potential_rides = @ride_upload.failed_potential_rides
  end

  # GET /admin/ride_zones/ca-25/ride_uploads/new
  def new
    @ride_upload = RideUpload.new
  end

  # GET /admin/ride_zones/ca-25/ride_uploads/1/edit
  def edit
  end

  # POST /admin/ride_zones/ca-25/ride_uploads
  def create
    @ride_upload = RideUpload.new(ride_upload_params)
    @ride_upload.user = current_user
    @ride_upload.ride_zone = @ride_zone
    
    if @ride_upload.total_rows > 1000
      redirect_to admin_ride_zone_ride_uploads_path(@ride_zone.slug), notice: 'CSVs can not be more than 1000 lines long.'
    else  
      
      # TODO: Should a radius check be added to PotentialRide, and should it be made geolocatable?
      if @ride_upload.pending!
        total_rows = 0
        successful_rows = 0
        CSV.parse(@ride_upload.csv.download, headers: true) do |row|
          total_rows += 1
          potential_ride = PotentialRide.new(ride_zone: @ride_zone, ride_upload: @ride_upload, status: :pending, row_number: total_rows)
          if potential_ride.populate_from_csv_row(row)
            successful_rows += 1 
          else
            potential_ride.fail_because("Failed to populate csv row #{row_number}")
          end
          potential_ride.save
        end
      
        @ride_upload.total_rows = total_rows
        @ride_upload.successful_rows = successful_rows
        @ride_upload.queued!
        @ride_upload.save
      
        redirect_to admin_ride_zone_ride_upload_path(@ride_zone.slug, @ride_upload), notice: 'Ride upload was successfully created, you still need to schedule the rides.'
      else
        render :new
      end
    end
  end
  
  # POST /admin/ride_zones/ca-25/ride_uploads/1
  # Go through all the PotentialRides associated with this RideUpload
  # If any can't be processed, fail the whole thing and don't process any
  # If all look like they can be scheduled, do so
  def schedule
    fail_count = 0
    
    # TODO: queue a single large job to create rides from potential_rides. Needs to be a single big
    # job, one per ride_upload, so that it can change the status of the ride_upload at the end.
    # - get rid of fail count, instead rely on counting PotentialRides in RideUpload with :failed status
    # - Move code below into a job: ConvertPotentialRidesJob
    # rails generate job convert_potential_rides_job --queue convert_potential_rides
    # ConvertPotentialRidesJob.perform_later potential_job
    # - block of code at end
    @ride_upload.potential_rides.each do |potential_ride|
      
      if user = User.find_from_potential_ride( potential_ride )
        if user.active_or_open_rides?
          potential_ride.fail_because("User already has an active or open ride"); fail_count += 1
          next
        else
          begin
            ride = Ride.create_from_potential_ride( potential_ride, user )
          rescue ActiveRecord::RecordInvalid => e
            potential_ride.fail_because("Found user, but record was invalid: #{e}"); fail_count += 1
          rescue Exception => e
            potential_ride.fail_because("Found user, failed, generally: #{e}"); fail_count += 1
          end
        end
      else
        begin
          user = User.create_from_potential_ride( potential_ride )
          potential_ride.voter = user
        rescue ActiveRecord::RecordInvalid => e
          potential_ride.fail_because("Could not create user: #{e}"); fail_count += 1
        end
        
        if potential_ride.voter.present?
          begin
            ride = Ride.create_from_potential_ride( potential_ride )
          rescue Exception => e
            potential_ride.fail_because("Created User, could not create Ride: #{e}"); fail_count += 1
          end
        end
      end
      
      if ride.present?
        Conversation.create_from_ride(ride, thanks_msg(ride))
        UserMailer.welcome_email_voter_ride(user, ride).deliver_later unless user.email&.include? "example.com"
      end
      
    end
    
    if fail_count == 0
      @ride_upload.complete!
      notice = "Rides were successfully scheduled."
    elsif fail_count < @ride_upload.total_rows
      @ride_upload.complete_with_failures!
      notice = "Some or all rides failed to schedule, please check logs or contact DtV help."
    else
      @ride_upload.failed!
      notice = "Scheduling rides failed."
    end

    redirect_to admin_ride_zone_ride_upload_path, notice: notice
  end

  # PATCH/PUT /admin/ride_zones/ca-25/ride_uploads/1
  def update
    if @ride_upload.update(ride_upload_params)
      redirect_to @ride_upload, notice: 'Ride upload was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/ride_zones/ca-25/ride_uploads/1
  def destroy
    @ride_upload.destroy
    redirect_to ride_uploads_url, notice: 'Ride upload was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ride_upload(param = :id)
      @ride_upload = RideUpload.find_by_id(params[param]) || RideUpload.find_by_slug(params[param])
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_ride_zone(param = :ride_zone_id)
      @ride_zone = RideZone.find_by_id(params[param]) || RideZone.find_by_slug(params[param])
      raise ActiveRecord::RecordNotFound.new unless @ride_zone
    end

    # Only allow a trusted parameter "white list" through.
    def ride_upload_params
      params.require(:ride_upload).permit(:user_id, :ride_zone_id, :name, :description, :csv, :status, :csv_hash)
    end
end
