class Admin::AdminApplicationController < ApplicationController
  
  before_filter :require_admin_priviledges

  private

    def require_admin_priviledges
      unless user_signed_in? && current_user.name == 'John McGrath'
        redirect_to root_path, notice: 'There was an error.'
      end
    end
    
end