require 'rails_helper'

RSpec.describe "/rides/new", type: :view do
  before(:each) do
    #   allow(view).to receive(:current_user).and_return( create(:user)  )
    #   assign(:ride, Ride.new(
    #     :name => "MyString",
    #     :description => "MyText",
    #     :status => 1
    #   ))
    @ride = Ride.new
    @ride_zone = create :ride_zone
  end

  it "renders" do
    render
  end
end
