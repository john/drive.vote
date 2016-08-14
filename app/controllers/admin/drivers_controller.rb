class Admin::DriversController < Admin::AdminApplicationController

  # GET /admin/drivers
  def index
    if params[:rz_id].present?
      @drivers = User.with_role( :driver, RideZone.find(params[:rz_id]) ).to_a
    elsif params[:all]
      @drivers = User.with_role(:driver).to_a
    else
      @drivers = User.with_role( :unassigned_driver ).to_a
    end
  end

end