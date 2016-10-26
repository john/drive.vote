require 'rails_helper'

RSpec.describe "admin/sites/edit", type: :view do
  before(:each) do
    @site = Site.instance
  end

  it "renders" do
    render
  end
end
