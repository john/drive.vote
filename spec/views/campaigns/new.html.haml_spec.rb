require 'rails_helper'

RSpec.describe "campaigns/new", type: :view do
  before(:each) do
    assign(:campaign, Campaign.new(
      :election_id => 1,
      :slug => "MyString",
      :name => "MyString",
      :description => "MyText"
    ))
  end

  it "renders new campaign form" do
    render

    assert_select "form[action=?][method=?]", campaigns_path, "post" do

      assert_select "input#campaign_election_id[name=?]", "campaign[election_id]"

      assert_select "input#campaign_slug[name=?]", "campaign[slug]"

      assert_select "input#campaign_name[name=?]", "campaign[name]"

      assert_select "textarea#campaign_description[name=?]", "campaign[description]"
    end
  end
end
