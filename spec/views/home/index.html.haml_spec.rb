require 'rails_helper'

RSpec.describe "home/index", :type => :view do

  it "renders when you're not logged in" do
    render
  end

  it "renders when you're logged in" do
    setup_user(:user)
    render
  end

end