require 'rails_helper'

RSpec.describe "campaigns/index", type: :view do
  before(:each) do
    assign(:campaigns, [
      create(:campaign),
      create(:campaign, election_id: 2, slug: 'Trump16', name: 'Trump 2016')
    ])
  end

  it "renders a list of campaigns" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 1
    assert_select "tr>td", :text => "hillary16".to_s, :count => 1
    assert_select "tr>td", :text => "Hillary 2016".to_s, :count => 1
    
    assert_select "tr>td", :text => 2.to_s, :count => 1
    assert_select "tr>td", :text => "Trump16".to_s, :count => 1
    assert_select "tr>td", :text => "Trump 2016".to_s, :count => 1
    
    assert_select "tr>td", :text => "A chicken in every pot.".to_s, :count => 2
  end
end
