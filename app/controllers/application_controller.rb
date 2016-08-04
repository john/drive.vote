class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # https://github.com/plataformatec/devise/pull/4033/files
  protect_from_forgery with: :exception, prepend: true

  class ConfigurationError < StandardError
  end

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    root_path
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
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
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_type, :name, :email, :phone_number, :zip])
  end
  
end