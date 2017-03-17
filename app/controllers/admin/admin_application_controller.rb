class Admin::AdminApplicationController < ApplicationController

  before_action :set_ride_zone
  before_action :require_admin_privileges

  private

  def set_ride_zone
    if params[:rz_id].present?
      @ride_zone = RideZone.find(params[:rz_id])
    end
  end

  def require_admin_privileges
    unless user_signed_in? && (current_user.has_role?(:admin) || (@ride_zone && current_user.has_role?(:admin, @ride_zone)))
      redirect_to '/404.html'
    end
  end

end