require 'rails_helper'

RSpec.describe "campaigns/show", type: :view do
  before(:each) do
    @campaign = assign(:campaign, create(:campaign))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/hillary16/)
    expect(rendered).to match(/Hillary 2016/)
    expect(rendered).to match(/A chicken in every pot./)
  end
end
