class Admin::AdminController < ApplicationController

  def index
    logger.debug "--------=============>>>>>>>>> FOO"
    render 'admin/index'
  end
  
end
