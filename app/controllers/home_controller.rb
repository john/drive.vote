class HomeController < ApplicationController
  http_basic_authenticate_with name: "hi", password: "comeonin", only: :index2
  
  skip_before_filter :go_complete_profile, :only => [:instructions, :terms_of_service]
  
  def index
    @user_count = User.count if user_signed_in?
    render template: "home/index2"
  end
  
  def index2
    @user_count = User.count if user_signed_in?
  end
  
  def about
  end
  
  def terms_of_service
  end
  
end
