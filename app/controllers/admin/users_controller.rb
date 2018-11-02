class Admin::UsersController < Admin::AdminApplicationController
  include UserParams

  before_action :set_user, only: [:show, :edit, :update, :destroy, :qa_clear]

  USER_SEARCH = "(lower(users.name) LIKE ?) OR (users.phone_number LIKE ?) OR (users.email LIKE ?) OR (lower(users.city) LIKE ?)".freeze

  def show
    @admin_zones = RideZone.with_user_in_role(@user, :admin)
    @dispatch_zones = RideZone.with_user_in_role(@user, :dispatcher)
    @driving_zones = RideZone.with_user_in_role(@user, :driver)
    @conversations = Conversation.where(user_id: @user.id)
  end

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    sort = params[:sort] || 'name'
    if params[:q].present?
      @q = params[:q].downcase
      @users = User.where(USER_SEARCH, "%#{@q}%", "%#{@q}%", "%#{@q}%", "%#{@q}%").order("UPPER(#{sort}) DESC").paginate(page: page, per_page: per_page)
    elsif params[:filter].present? && params[:filter].downcase != 'all'
      @users = User.with_role(params[:filter].to_sym, :any).order("#{sort} DESC").paginate(page: page, per_page: per_page)
    else
      @users = User.users.order(Arel.sql("UPPER(#{sort}) ASC")).paginate(page: page, per_page: per_page)
    end
  end

  def voters
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    sort = params[:sort] || 'users.name'
    if params[:q].present?
      @q = params[:q].downcase
      @users = User.voters.where(USER_SEARCH, "%#{@q}%", "%#{@q}%", "%#{@q}%", "%#{@q}%").order("#{sort} DESC").paginate(page: page, per_page: per_page)
    else
      @users = User.voters.order(:name).paginate(page: page, per_page: per_page)
    end
    render template: 'admin/users/voters'
  end

  def edit
    @user.superadmin = @user.has_role?(:admin)
    @zones_driving_for = RideZone.with_user_in_role(@user, :driver)
    @zones_dispatching_for = RideZone.with_user_in_role(@user, :dispatcher)
  end

  def qa_clear
    @user.qa_clear
    flash[:notice] = "Cleared all data for #{@user.name}"
    redirect_back(fallback_location: admin_users_path)
  end

  def destroy
    @user.destroy
    flash[:notice] = "Deleted #{@user.name}"
    redirect_to admin_users_path
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
