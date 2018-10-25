require 'rails_helper'

RSpec.describe "admin/ride_uploads/show", type: :view do
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

  it "renders attributes in <p>" do
    pending "not sure how to handle the attachment"
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
