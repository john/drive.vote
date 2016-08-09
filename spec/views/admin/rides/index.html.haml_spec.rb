require 'rails_helper'

RSpec.describe "admin/rides/index", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user)  )

    first_ride = create :ride
    second_ride = create :ride

    assign(:rides, [create(:ride), create(:ride)])
  end

  it "renders" do
    render
    # assert_select "tr>td", :text => 2.to_s, :count => 2
    # assert_select "tr>td", :text => "Name".to_s, :count => 2
    # assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
