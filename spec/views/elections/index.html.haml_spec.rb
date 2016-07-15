require 'rails_helper'

RSpec.describe "elections/index", type: :view do
  before(:each) do
    assign(:elections, [
      create(:election, name: '2016 Presidential Election', slug: 'pres2016'),
      create(:election, name: '2020 Presidential Election', slug: 'pres2020')
    ])
  end

  it "renders a list of elections" do
    render
    assert_select "tr>td", :text => "2016 Presidential Election".to_s, :count => 1
    assert_select "tr>td", :text => "pres2016".to_s, :count => 1
    
    assert_select "tr>td", :text => "2020 Presidential Election".to_s, :count => 1
    assert_select "tr>td", :text => "pres2020".to_s, :count => 1
    
    assert_select "tr>td", :text => "For the big one. Our supreme leader.".to_s, :count => 2
  end
end
