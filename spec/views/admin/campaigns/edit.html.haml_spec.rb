require 'rails_helper'

RSpec.describe "admin/campaigns/edit", type: :view do
  before(:each) do
    @campaign = assign(:campaign, create(:campaign))
  end

  it "renders the edit campaign form" do
    render

    assert_select "form[action=?][method=?]", admin_campaign_path(@campaign), "post" do

      assert_select "select#campaign_election_id[name=?]", "campaign[election_id]"

      assert_select "input#campaign_slug[name=?]", "campaign[slug]"

      assert_select "input#campaign_name[name=?]", "campaign[name]"

      assert_select "textarea#campaign_description[name=?]", "campaign[description]"
    end
  end
end
