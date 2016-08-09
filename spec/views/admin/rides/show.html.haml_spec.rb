require 'rails_helper'

RSpec.describe "admin/rides/show", type: :view do
  before(:each) do
    test_ride = create :ride
    @ride = assign(:ride, test_ride)
  end

  it "renders" do
    render
  end
end
