require 'rails_helper'

RSpec.describe "admin/messages/show", :type => :view do
  before(:each) do
    @message = assign(:message, create(:message))
  end

  it "renders a message" do
    render
  end
end
