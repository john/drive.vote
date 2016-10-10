require 'rails_helper'

RSpec.describe "admin/metrics/index", :type => :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )
  end

  it "renders admin metrics page" do
    render
  end
end
