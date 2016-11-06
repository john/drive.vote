class Users::RegistrationsController < Devise::RegistrationsController

  skip_before_action :require_no_authentication, only: [:new, :create]

  # GET /resource/sign_up
  # GET /volunteer_to_drive
  def new
    resource = build_resource({})

    if request.path.include?('volunteer')

      if params[:id]&.downcase == 'philadelphia'
        flash[:notice] = 'Sorry, no longer accepting volunteers at that location.'
        redirect_to root_path and return
      end

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
      else
        render layout: false, file: "#{Rails.root}/public/404.html",  status: 404 and return
      end
    end

    respond_with resource
  end

  # POST /resource
  # Overridden so that when people sign up to volunteer, they're not automatically signed in
  def create
    build_resource(sign_up_params)

    unless resource.password.present?
      generated_password = Devise.friendly_token.first(8)
      resource.password = generated_password
    end

    if resource.city_state.present? && resource.city.blank? && resource.state.blank?
      resource.parse_city_state()
    end
    resource.save

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up

        if resource.ride_zone_id.present?
          @ride_zone = RideZone.find(resource.ride_zone_id)
          UserMailer.welcome_email_driver(resource, @ride_zone).deliver_later
        else
          UserMailer.welcome_email_driver(resource).deliver_later
        end

        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      @ride_zone = RideZone.find_by_slug(params[:id]) if params.has_key?(:id)
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)
    if user_signed_in? && current_user.has_role?(:admin)
      admin_users_path
    else
      confirm_path
    end
  end

end
