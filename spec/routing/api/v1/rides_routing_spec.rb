require 'rails_helper'

RSpec.describe Api::V1::RidesController, :type => :routing do
  describe 'routing' do

    it 'routes to update_attribute' do
      expect(post: '/api/1/rides/41/update_attribute').to route_to('api/v1/rides#update_attribute', id: '41')
    end

    it 'routes to confirm scheduled' do
      expect(post: '/api/1/rides/confirm_scheduled').to route_to('api/v1/rides#confirm_scheduled')
    end
  end
end