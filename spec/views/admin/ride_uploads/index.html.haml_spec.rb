require 'rails_helper'

RSpec.describe "admin/ride_uploads/index", type: :view do
  before(:each) do
    
    allow(view).to receive(:current_user).and_return( create(:user) )
    @ride_zone = assign(:ride_zone, create(:ride_zone))
    @ride_upload = assign(:ride_upload, RideUpload.create!(
      :user => create(:user),
      :ride_zone => @ride_zone,
      :name => "Name1",
      :description => "MyText",
      :status => 2
    ))
    
    
    assign(:scheduled_ride_uploads, [
      RideUpload.create!(
            :user => create(:user),
            :ride_zone => @ride_zone,
            :name => "Name2",
            :description => "MyText",
            :status => 2
          )
    ])
  end

  it "renders a list of scheduled_ride_uploads" do
    pending
    render
    assert_select "tr>td", :text => nil.to_s, :count => 1
    assert_select "tr>td", :text => nil.to_s, :count => 1
    assert_select "tr>td", :text => "Name1".to_s, :count => 1
    assert_select "tr>td", :text => "MyText".to_s, :count => 1
    assert_select "tr>td", :text => 2.to_s, :count => 1
  end
end
