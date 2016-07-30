class HomeController < ApplicationController
  # http_basic_authenticate_with name: "hi", password: "comeonin", only: :index
  
  skip_before_action :go_complete_profile, :only => [:instructions, :terms_of_service, :privacy]
  
  def index
    @is_new_user = params['is_new_user'].present?
  end
  
  def coming_soon
  end
  
  def about
  end
  
  def terms_of_service
  end
  
  def privacy
  end
  
end
