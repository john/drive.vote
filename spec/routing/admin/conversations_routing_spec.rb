require 'rails_helper'

RSpec.describe Admin::ConversationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/conversations').to route_to('admin/conversations#index')
    end

    it 'routes to #show' do
      expect(get: '/admin/conversations/1').to route_to('admin/conversations#show', id: '1')
    end

    it 'routes to #messages' do
      expect(get: '/admin/conversations/1/messages').to route_to('admin/conversations#messages', id: '1')
    end

    it 'routes to #ride_pane' do
      expect(get: '/admin/conversations/1/ride_pane').to route_to('admin/conversations#ride_pane', id: '1')
    end

    it 'routes to #close' do
      expect(post: '/admin/conversations/1/close').to route_to('admin/conversations#close', id: '1')
    end
  end
end
