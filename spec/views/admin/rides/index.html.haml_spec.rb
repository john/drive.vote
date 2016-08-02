require 'rails_helper'

RSpec.describe "admin/rides/index", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user)  )
    assign(:rides, [
      Ride.create!(
        :owner_id => 1,
        :campaign_id => 2,
        :name => "Name",
        :description => "MyText",
        :status => 0
      ),
      Ride.create!(
        :owner_id => 1,
        :campaign_id => 2,
        :name => "Name",
        :description => "MyText",
        :status => 0
      )
    ])
  end

  it "renders" do
    render
    # assert_select "tr>td", :text => 2.to_s, :count => 2
    # assert_select "tr>td", :text => "Name".to_s, :count => 2
    # assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
