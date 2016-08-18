module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      admin = FactoryGirl.create(:admin_user)
      sign_in admin, scope: :user
    end
  end

  def login_dispatcher
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      dispatcher_user = FactoryGirl.create(:dispatcher_user)
      sign_in dispatcher_user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
    end
  end
end