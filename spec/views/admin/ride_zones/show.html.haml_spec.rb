require 'rails_helper'

RSpec.describe "admin/ride_zones/show", :type => :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )
    @messages = assign(:messages, [])
    @ride_zone = assign(:ride_zone, create(:ride_zone))
  end

  it "renders a ride area" do
    render
  end
end
