require 'rails_helper'

RSpec.describe DispatchController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/dispatch/1').to route_to('dispatch#show', id: '1')
    end

    it 'routes to #drivers' do
      expect(get: '/dispatch/1/drivers').to route_to('dispatch#drivers', id: '1')
    end

    it 'routes to #map' do
      expect(get: '/dispatch/1/map').to route_to('dispatch#map', id: '1')
    end
  end
end
