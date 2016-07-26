require 'rails_helper'

RSpec.describe "admin/ride_areas/show", :type => :view do
  before(:each) do
    @ride_area = assign(:ride_area, create(:ride_area))
  end

  it "renders a ride area" do
    render
  end
end
