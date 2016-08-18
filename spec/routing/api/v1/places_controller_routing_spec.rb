require 'rails_helper'

RSpec.describe Api::V1::PlacesController, :type => :routing do
  describe 'routing' do

    it 'routes to search' do
      expect(get: '/api/1/places/search').to route_to('api/v1/places#search')
    end
  end
end
