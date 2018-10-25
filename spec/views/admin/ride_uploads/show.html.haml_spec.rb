require 'rails_helper'

RSpec.describe "admin/ride_uploads/show", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )
    @ride_zone = assign(:ride_zone, create(:ride_zone))
    @ride_upload = assign(:ride_upload, create(:ride_upload_with_csv))
  end

  it "renders" do
    render
    expect(rendered).to match(/test ride upload foo good/)
  end
end
