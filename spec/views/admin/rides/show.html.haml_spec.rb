require 'rails_helper'

RSpec.describe "admin/rides/show", type: :view do
  before(:each) do
    @ride = assign(:ride, Ride.create!(
      :owner_id => 1,
      :campaign_id => 2,
      :name => "Name",
      :description => "MyText",
      :status => 0
    ))
  end

  it "renders" do
    render
  #   expect(rendered).to match(/2/)
  #   expect(rendered).to match(/Name/)
  #   expect(rendered).to match(/MyText/)
  #   expect(rendered).to match(/0/)
  end
end
