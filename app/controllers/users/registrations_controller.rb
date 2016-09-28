class Users::RegistrationsController < Devise::RegistrationsController

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # GET /volunteer_to_drive

  skip_before_action :require_no_authentication, only: [:new, :create]

  def new
    resource = build_resource({})

    if request.path.include?('volunteer_to_drive')
      @volunteer = true
      resource.user_type = 'unassigned_driver'
    end

    if params[:type].present?
      if params[:type] == 'unassigned_driver'
        resource.user_type = params[:type]
      else
        redirect_to root_path and return
      end
    end

    if params[:id].present?
      if @ride_zone = RideZone.find_by_slug(params[:id])
        resource.ride_zone_id = @ride_zone.id
      end
    end

    respond_with resource
  end

  # POST /resource
  # Overridden so that when people sign up to volunteer, they're not automatically signed in
  def create
    build_resource(sign_up_params)
    generated_password = Devise.friendly_token.first(8)
    resource.password = generated_password

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        # sign_up(resource_name, resource)
        logger.debug "-------------> 1"
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        logger.debug "-------------> 2"
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      logger.debug "-------------> 3"
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)
    confirm_path
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
