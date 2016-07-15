require 'rails_helper'

RSpec.describe "elections/show", type: :view do
  before(:each) do
    @election = assign(:election, create(:election))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/pres16/)
    expect(rendered).to match(/2016 Presidential Election/)
    expect(rendered).to match(/For the big one. Our supreme leader./)
  end
end
