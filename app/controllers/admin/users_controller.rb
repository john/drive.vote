class Admin::UsersController < Admin::AdminApplicationController
  include UserParams
  
  before_action :set_user, only: [:destroy]
  
  def index
    @users = User.all
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

end
