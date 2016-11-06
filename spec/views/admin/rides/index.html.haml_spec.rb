require 'rails_helper'

RSpec.describe "admin/rides/index", type: :view do
  before(:each) do
    allow(view).to receive(:current_user).and_return( create(:user)  )
    assign(:rides, [create(:ride), create(:ride)])
  end

  it "renders a list of rides" do
    allow(view).to receive_messages(:will_paginate => nil)
    render
  end
end
