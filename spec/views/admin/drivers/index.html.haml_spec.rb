require 'rails_helper'

RSpec.describe "admin/drivers/index", :type => :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )

    rz = create :ride_zone
    assign(:drivers, [create(:driver_user)])
  end

  it "renders admin drivers page" do
    render
  end
end
