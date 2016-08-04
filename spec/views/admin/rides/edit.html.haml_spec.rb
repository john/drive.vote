require 'rails_helper'

RSpec.describe "admin/rides/edit", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user)  )
    @ride = assign(:ride, Ride.create!(
      :owner_id => 1,
      :name => "MyString",
      :description => "MyText",
      :status => 1
    ))
  end

  it "renders" do
    render

    # assert_select "form[action=?][method=?]", ride_path(@ride), "post" do
    #
    #   assert_select "input#ride_name[name=?]", "ride[name]"
    #
    #   assert_select "textarea#ride_description[name=?]", "ride[description]"
    #
    #   assert_select "input#ride_status[name=?]", "ride[status]"
    # end
  end
end
