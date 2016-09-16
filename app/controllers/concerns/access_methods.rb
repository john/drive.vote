module AccessMethods
  extend ActiveSupport::Concern

  private

  def is_internal_user?
    return user_signed_in? &&
      ( current_user.is_super_admin? ||
        current_user.is_zone_admin? ||
        current_user.is_dispatcher? ||
        current_user.is_driver?
      )
  end

  def has_zone_rights?(zone)
    return user_signed_in? &&
      ( current_user.is_super_admin? ||
        current_user.has_role?(:admin, zone) ||
        current_user.has_role?(:dispatcher, zone) ||
        current_user.has_role?(:driver, zone)
      )
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

  ## before filters:

  def require_internal_access
    unless is_internal_user?
      redirect_to '/404.html'
    end
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

  def require_zone_access
    unless user_signed_in? && has_zone_rights?(@ride_zone)
      redirect_to '/404.html'
    end
  end

  def require_ride_access
    unless user_signed_in? && has_zone_rights?(@ride.ride_zone)
      redirect_to '/404.html'
    end
  end

  def require_conversation_access
    unless user_signed_in? && has_zone_rights?(@conversation.ride_zone)
      redirect_to '/404.html'
    end
  end

end