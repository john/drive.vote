require 'rails_helper'

RSpec.describe "campaigns/edit", type: :view do
  before(:each) do
    @campaign = assign(:campaign, Campaign.create!(
      :election_id => 1,
      :slug => "MyString",
      :name => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit campaign form" do
    render

    assert_select "form[action=?][method=?]", campaign_path(@campaign), "post" do

      assert_select "input#campaign_election_id[name=?]", "campaign[election_id]"

      assert_select "input#campaign_slug[name=?]", "campaign[slug]"

      assert_select "input#campaign_name[name=?]", "campaign[name]"

      assert_select "textarea#campaign_description[name=?]", "campaign[description]"
    end
  end
end
