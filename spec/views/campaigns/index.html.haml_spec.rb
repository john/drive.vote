require 'rails_helper'

RSpec.describe "campaigns/index", type: :view do
  before(:each) do
    assign(:campaigns, [
      Campaign.create!(
        :election_id => 2,
        :slug => "Slug",
        :name => "Name",
        :description => "MyText"
      ),
      Campaign.create!(
        :election_id => 2,
        :slug => "Slug",
        :name => "Name",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of campaigns" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
