class Admin::DriversController < Admin::AdminApplicationController

  # GET /admin/drivers
  def index
    if params[:rz_id].present?
      @drivers = RideZone.find(params[:rz_id])&.drivers&.to_a || []
    elsif params[:all]
      @drivers = User.all_drivers
    elsif params[:assigned]
      @drivers = User.assigned_drivers
    else
      @drivers = User.unassigned_drivers
    end
  end

end