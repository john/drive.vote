require 'rails_helper'

RSpec.describe "elections/edit", type: :view do
  before(:each) do
    @election = assign(:election, Election.create!(
      :slug => "MyString",
      :name => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit election form" do
    render

    assert_select "form[action=?][method=?]", election_path(@election), "post" do

      assert_select "input#election_slug[name=?]", "election[slug]"

      assert_select "input#election_name[name=?]", "election[name]"

      assert_select "textarea#election_description[name=?]", "election[description]"
    end
  end
end
