class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :set_locale
  before_action :go_complete_profile
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def go_complete_profile
    if user_signed_in? && current_user.missing_required_fields? && !request.original_url.include?('/edit')
      redirect_to edit_user_path(current_user)
    end
  end
  
end
