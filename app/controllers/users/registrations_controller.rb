class Users::RegistrationsController < Devise::RegistrationsController

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    resource = build_resource({})

    if params[:type].present?
      if params[:type] == 'unassigned_driver'
        resource.user_type = params[:type]
      else
        redirect_to root_path and return
      end
    end
    respond_with resource
  end

  # POST /resource
  def create

    # validate if it's a swing state zip
    #if swing_state_zip?( params[:zip] )
      super
      #else
      #redirect_to new_user_registration_path, notice: "Sorry not a battleground zip code!"
      #end
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

  # When new users sign up, we don't want them automatically signed in
  # http://stackoverflow.com/questions/18545306/dont-allow-sign-in-after-sign-up-in-devise
  def sign_up(resource_name, resource)
    true
  end

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
