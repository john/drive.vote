class Admin::DriversController < Admin::AdminApplicationController

  # GET /admin/drivers
  def index
    if params[:rz_id].present?
      @drivers = User.with_role( :driver, RideZone.find(params[:rz_id]) ).to_a
    elsif params[:all]
      @drivers = User.all_drivers
    elsif params[:assigned]
      @drivers = User.assigned_drivers
    else
      @drivers = User.with_role( :unassigned_driver ).to_a
    end
  end

end