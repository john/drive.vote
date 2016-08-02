require 'rails_helper'

RSpec.describe "admin/rides/new", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user)  )
    assign(:ride, Ride.new(
      :campaign_id => 1,
      :name => "MyString",
      :description => "MyText",
      :status => 1
    ))
  end

  it "renders" do
    render

    # assert_select "form[action=?][method=?]", rides_path, "post" do
    #
    #   assert_select "input#ride_campaign_id[name=?]", "ride[campaign_id]"
    #
    #   assert_select "input#ride_name[name=?]", "ride[name]"
    #
    #   assert_select "textarea#ride_description[name=?]", "ride[description]"
    #
    #   assert_select "input#ride_status[name=?]", "ride[status]"
    # end
  end
end
