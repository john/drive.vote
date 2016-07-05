class HomeController < ApplicationController
  http_basic_authenticate_with name: "hi", password: "comeonin"
  
  def index
    @user_count = User.count
  end
  
  def faq
  end
  
end
