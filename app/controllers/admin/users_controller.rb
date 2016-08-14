class Admin::UsersController < Admin::AdminApplicationController
  include UserParams
  include UserRoles

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def show
    @dispatch_zone = RideZone.with_role(:dispatcher, @user).first
    @driving_zone = RideZone.with_role(:driver, @user).first

  def index
    @users = User.all
  end

  def destroy
    @user.destroy
    redirect_to admin_users_url, notice: 'User was successfully destroyed.'
  end

  def edit
    # role_ids = []
    # Role.all.each do |role|
    #   role_ids << role.id if @user.has_role? role.name.to_sym
    # end
    # @user.role_ids = role_ids
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
