class HomeController < ApplicationController
  
  def index
    @user_count = User.count
  end
  
end
