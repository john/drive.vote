require 'rails_helper'

RSpec.describe 'admin/conversations/show', type: :view do
  before(:each) do
    assign(:conversation, create(:conversation))
  end

  it 'renders' do
    render
  end
end
