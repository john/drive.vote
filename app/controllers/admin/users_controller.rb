class Admin::UsersController < Admin::AdminApplicationController
  include UserParams

  before_action :set_user, only: [:show, :edit, :update, :destroy, :qa_clear]

  def show
    @admin_zones = RideZone.with_role(:admin, @user)
    @dispatch_zones = RideZone.with_role(:dispatcher, @user)
    @driving_zones = RideZone.with_role(:driver, @user)
    @conversations = Conversation.where(user_id: @user.id)
  end

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    if params[:q].present?
      @users = User.where("lower(name) LIKE ?", "%#{params[:q].downcase}%").paginate(page: page, per_page: per_page)
      @q = params[:q]
    elsif params[:filter].present?
      @users = User.with_role(params[:filter].to_sym, :any).order(:name).paginate(page: page, per_page: per_page)
    else
      @users = User.non_voters.order(:name).paginate(page: page, per_page: per_page)
    end
  end

  def edit
    @user.superadmin = @user.has_role?(:admin)
    @zones_driving_for = RideZone.with_role(:driver, @user)
    @zones_dispatching_for = RideZone.with_role(:dispatcher, @user)
  end

  def qa_clear
    @user.qa_clear
    flash[:notice] = "Cleared all data for #{@user.name}"
    redirect_back(fallback_location: admin_users_path)
  end

  # # PATCH/PUT /users/1
  # # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)

        if @user.superadmin == 'true'
          @user.add_role(:admin)
        else
          @user.remove_role(:admin)
        end

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
