class HomeController < ApplicationController
  
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
