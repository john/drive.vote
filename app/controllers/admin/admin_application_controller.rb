class Admin::AdminApplicationController < ApplicationController
  
  before_filter :require_admin_priviledges

  private

    def require_admin_priviledges
      
      logger.debug '--------------'
      logger.debug "Current user logged in? #{user_signed_in?}"
      logger.debug '--------------'
      unless user_signed_in? && current_user.is_admin?
        redirect_to '/404.html'
      end
    end
    
end