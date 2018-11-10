module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      admin = FactoryBot.create(:admin_user)
      sign_in admin, scope: :user
    end
  end

  def login_rz_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      rz_admin_user = FactoryBot.create(:zoned_admin_user, rz: (defined? rz) ? rz : create(:ride_zone))
      sign_in rz_admin_user
    end
  end

  # If rz is defined as a let variable within the rspec block, the created dispatcher will be
  # associated with that rz. If none is defined, a new rz is created.
  def login_dispatcher
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:dispatcher_user]
      dispatcher_user = FactoryBot.create(:dispatcher_user, rz: (defined? rz) ? rz : create(:ride_zone))
      sign_in dispatcher_user, scope: :user
    end
  end

  def login_driver
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      driver_user = FactoryBot.create(:driver_user, rz: (defined? rz) ? rz : create(:ride_zone))
      sign_in driver_user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      sign_in user
    end
  end

  def login_voter
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:voter_user)
      sign_in user
    end
  end

end
