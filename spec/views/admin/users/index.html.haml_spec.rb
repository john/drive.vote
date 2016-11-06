require 'rails_helper'

RSpec.describe "admin/users/index", :type => :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user)  )
    assign(:users, [
      create(:user, name: 'user1', email: 'a@b.com'),
      create(:user, name: 'user2', email: 'c@d.com', reset_password_token: 'blah')
    ])
  end

  it "renders a list of users" do
    allow(view).to receive_messages(:will_paginate => nil)
    render
  end
end
