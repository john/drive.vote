require 'rails_helper'

RSpec.describe "admin/sites/show", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )
    @site = Site.instance
  end

  it "renders" do
    render
  end
end
