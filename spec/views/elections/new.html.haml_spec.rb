require 'rails_helper'

RSpec.describe "elections/new", type: :view do
  before(:each) do
    assign(:election, Election.new(
      :slug => "MyString",
      :name => "MyString",
      :description => "MyText"
    ))
  end

  it "renders new election form" do
    render

    assert_select "form[action=?][method=?]", elections_path, "post" do

      assert_select "input#election_slug[name=?]", "election[slug]"

      assert_select "input#election_name[name=?]", "election[name]"

      assert_select "textarea#election_description[name=?]", "election[description]"
    end
  end
end
