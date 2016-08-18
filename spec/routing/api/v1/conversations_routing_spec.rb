require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, :type => :routing do
  describe 'routing' do

    it 'routes to show' do
      expect(get: '/api/1/conversations/42').to route_to('api/v1/conversations#show', id: '42')
    end

    it 'routes to update' do
      expect(put: '/api/1/conversations/42').to route_to('api/v1/conversations#update', id: '42')
    end

    it 'routes to create message' do
      expect(post: '/api/1/conversations/42/messages').to route_to('api/v1/conversations#create_message', id: '42')
    end

  end
end
