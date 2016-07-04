require 'rails_helper'

RSpec.describe "elections/index", type: :view do
  before(:each) do
    assign(:elections, [
      Election.create!(
        :slug => "Slug",
        :name => "Name",
        :description => "MyText"
      ),
      Election.create!(
        :slug => "Slug",
        :name => "Name",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of elections" do
    render
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
