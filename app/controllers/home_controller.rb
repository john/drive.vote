class HomeController < ApplicationController
  http_basic_authenticate_with name: "hi", password: "comeonin"
  
  skip_before_filter :go_complete_profile, :only => [:instructions]
  
  def index
    @user_count = User.count
  end
  
  def about
  end
  
end
