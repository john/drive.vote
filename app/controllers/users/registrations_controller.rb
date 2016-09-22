class Users::RegistrationsController < Devise::RegistrationsController

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # GET /volunteer_to_drive
  def new
    resource = build_resource({})

    if request.path.include?('volunteer_to_drive')
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
  def create
    super
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
