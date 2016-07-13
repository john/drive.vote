class HomeController < ApplicationController
  http_basic_authenticate_with name: "hi", password: "comeonin"
  
  skip_before_filter :go_complete_profile, :only => [:instructions]
  
  def index
  end
  
  def instructions
  end
  
  def about
  end
  
end
