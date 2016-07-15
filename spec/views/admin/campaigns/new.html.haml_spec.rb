require 'rails_helper'

RSpec.describe "admin/campaigns/new", type: :view do
  before(:each) do
    assign(:campaign, create(:campaign))
  end

  it "renders new campaign form" do
    render

    # assert_select "form[action=?][method=?]", admin_campaigns_path, "post" do
    #
    #   assert_select "input#campaign_election_id[name=?]", "campaign[election_id]"
    #
    #   assert_select "input#campaign_slug[name=?]", "campaign[slug]"
    #
    #   assert_select "input#campaign_name[name=?]", "campaign[name]"
    #
    #   assert_select "textarea#campaign_description[name=?]", "campaign[description]"
    # end
  end
end
