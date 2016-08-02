require 'rails_helper'

RSpec.describe "admin/elections/edit", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user) )
    @election = assign(:election, create(:election))
  end

  it "renders the edit election form" do
    render

    assert_select "form[action=?][method=?]", admin_election_path(@election), "post" do

      assert_select "input#election_slug[name=?]", "election[slug]"

      assert_select "input#election_name[name=?]", "election[name]"

      assert_select "textarea#election_description[name=?]", "election[description]"
    end
  end
end
