class HomeController < ApplicationController
  http_basic_authenticate_with name: "hi", password: "comeonin"
  
  def index
  end
  
  def instructions
  end
  
  def about
  end
  
end
