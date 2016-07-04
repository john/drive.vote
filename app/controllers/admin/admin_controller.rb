class Admin::AdminController < Admin::AdminApplicationController

  def index
    logger.debug "--------=============>>>>>>>>> FOO"
    render 'admin/index'
  end
  
end
