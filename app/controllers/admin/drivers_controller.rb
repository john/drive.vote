class Admin::DriversController < Admin::AdminApplicationController
  
  DRIVER_SEARCH = "(lower(users.name) LIKE ?) OR (users.phone_number LIKE ?) OR (users.email LIKE ?) OR (lower(users.city) LIKE ?)".freeze
  
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    # sort = params[:sort] || 'user.name'
    
    if params[:rz_id].present?
      @drivers = RideZone.find(params[:rz_id])&.drivers&.to_a || []
    elsif params[:all]
      @drivers = User.all_drivers
      
    elsif params[:q].present?
      @q = params[:q].downcase
      @drivers = User.all_drivers.where(DRIVER_SEARCH, "%#{@q}%", "%#{@q}%", "%#{@q}%", "%#{@q}%").order("name DESC").paginate(page: page, per_page: per_page)
    elsif params[:assigned]
      @drivers = User.assigned_drivers
    else
      @drivers = User.unassigned_drivers
    end
  end

  def toggle_available
    if params[:id].present?
      driver = User.find(params[:id])

      driver.update_attribute :available, !driver.available
      driver.save!
      msg = "#{driver.name} is now #{driver.available? ? 'on' : 'off'} duty"
    else
      msg = "I can't really do anything without a driver ID."
    end

    flash[:notice] = msg
    redirect_back(fallback_location: root_path)
  end
end