module GetDateFromPicker
  extend ActiveSupport::Concern

  def transfer_date_to_pickup_at
    if self.pickup_at.blank?
      if Chronic.parse(params[:pickup_day]) && Chronic.parse(params[:pickup_time])
        from_date_time = Chronic.parse( [params[:pickup_day], params[:pickup_time]].join(' ') )
        @ride.pickup_at =  from_date_time
      else
        @ride.errors.add(:pickup_at, :invalid)
        @msg = "Please fill in scheduled date and time."
        flash[:notice] = @msg
        redirect_back(fallback_location: root_path) and return
      end
    end
  end

end