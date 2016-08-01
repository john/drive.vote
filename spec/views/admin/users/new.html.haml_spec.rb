require 'rails_helper'

RSpec.describe "users/new", :type => :view do
  before(:each) do
    assign(:user, User.new())
  end

  it "renders new user form" do
    skip
    render

    assert_select "form[action=?][method=?]", users_path, "post" do
    end
  end
end
