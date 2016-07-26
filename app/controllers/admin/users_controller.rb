class Admin::UsersController < Admin::AdminApplicationController
  before_action :set_user, only: [:destroy]
  
  def index
    @users = User.all
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

end
