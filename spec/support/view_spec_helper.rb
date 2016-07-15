module ViewSpecHelper

  def setup_user(user_factory = :user, extra_attrs = {})
    @user = create(user_factory, extra_attrs)
    allow(@controller).to receive(:current_user).and_return(@user)
    allow(view).to receive(:current_user).and_return(@user)
  end
end

RSpec.configure do |config|
  config.include ViewSpecHelper, type: :view
end
