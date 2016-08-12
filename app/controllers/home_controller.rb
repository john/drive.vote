class HomeController < ApplicationController

  def index
    @is_new_user = params['is_new_user'].present?
  end

  def confirm
  end

  def about
  end

  def code_of_conduct
  end

  def terms_of_service
  end

  def privacy
  end

end
