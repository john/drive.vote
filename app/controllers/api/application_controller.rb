module Api
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception, prepend: true

    protected

    def has_zone_rights?(zone)
      return user_signed_in? &&
        ( current_user.has_role?(:admin) ||
          current_user.has_role?(:admin, zone) ||
          current_user.has_role?(:dispatcher, zone) ||
          current_user.has_role?(:driver, zone)
        )
    end

  end
end

