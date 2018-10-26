require 'rails_helper'

RSpec.describe "admin/ride_uploads/edit", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )
    @ride_zone = assign(:ride_zone, create(:ride_zone))
    @ride_upload = assign(:ride_upload, RideUpload.create!(
      :user => create(:user),
      :ride_zone => @ride_zone,
      :name => "Name",
      :description => "MyText",
      :status => 2
    ))
  end

  it "renders the edit ride_upload form" do
    pending
    render

    assert_select "form[action=?][method=?]", ride_upload_path(@ride_upload), "post" do

      assert_select "input#ride_upload_user_id[name=?]", "ride_upload[user_id]"

      assert_select "input#ride_upload_ride_zone_id[name=?]", "ride_upload[ride_zone_id]"

      assert_select "input#ride_upload_name[name=?]", "ride_upload[name]"

      assert_select "textarea#ride_upload_description[name=?]", "ride_upload[description]"

      assert_select "input#ride_upload_status[name=?]", "ride_upload[status]"
    end
  end
end
