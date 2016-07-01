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
    if user_signed_in? &&
        current_user.missing_required_fields? &&
        !request.original_url.include?('/edit') &&
        !request.original_url.include?('/sign_out')
      redirect_to edit_user_path(current_user)
    end
  end
  
  def check_for_user_type(parms)
    if parms.has_key?('type')
      if parms['type'] == 'driver'
        return 'driver'
      elsif parms['type'] == 'rider'
        return 'rider'
      else
        return nil
      end
    end
  end
  
end
