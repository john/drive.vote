module RideZoneParams
  extend ActiveSupport::Concern

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ride_zone(param = :id)
    @ride_zone = RideZone.find_by_id(params[param]) || RideZone.find_by_slug(params[param])
  end

  # Only allow a trusted parameter "white list" through.
  def ride_zone_params
    params.require(:ride_zone).permit(:name, :description, :phone_number, :short_code, :city, :county,
                                      :state, :zip, :country, :latitude, :longitude, :slug, :bot_disabled,
                                      :admin_name, :admin_email, :admin_phone_number, :admin_password)
  end

  def has_zone_dispatch?
    return user_signed_in? &&
      ( current_user.has_role?(:admin) ||
        current_user.has_role?(:admin, @ride_zone) ||
        current_user.has_role?(:dispatcher, @ride_zone)
      )
  end

  def has_zone_admin?
    return user_signed_in? &&
      ( current_user.has_role?(:admin) ||
        current_user.has_role?(:admin, @ride_zone)
      )
  end

  def require_zone_dispatch
    unless has_zone_dispatch?
      redirect_to '/404.html'
    end
  end

  def require_zone_admin
    unless has_zone_admin?
      redirect_to '/404.html'
    end
  end

end
