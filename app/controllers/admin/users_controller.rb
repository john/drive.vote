class Admin::UsersController < Admin::AdminApplicationController
  include UserParams
  include UserRoles

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def show
    @admin_zones = RideZone.with_role(:admin, @user)
    @dispatch_zones = RideZone.with_role(:dispatcher, @user)
    @driving_zones = RideZone.with_role(:driver, @user)
  end

  def index
    if params[:filter].present?
      @users = User.with_role(params[:filter].to_sym, :any)
    else
      @users = User.non_voters
    end
  end

  def edit
    @zones_driving_for = RideZone.with_role(:driver, @user)
    @zones_dispatching_for = RideZone.with_role(:driver, @user)
  end

  # # PATCH/PUT /users/1
  # # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if update_user_roles(params) && @user.update(user_params)
        format.html do
          redirect_to admin_users_path, notice: 'User was successfully updated.', locale: I18n.locale.to_s
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

end
