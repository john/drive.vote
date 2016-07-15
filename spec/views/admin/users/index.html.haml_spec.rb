require 'rails_helper'

RSpec.describe "admin/users/index", :type => :view do
  before(:each) do
    assign(:users, [
      create(:user, name: 'user1', email: 'a@b.com'),
      create(:user, name: 'user2', email: 'c@d.com', uid: '234567654', reset_password_token: 'blah')
    ])
  end

  it "renders a list of users" do
    render
  end
end
