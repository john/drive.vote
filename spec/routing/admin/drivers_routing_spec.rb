require 'rails_helper'

RSpec.describe Admin::DriversController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/drivers').to route_to('admin/drivers#index')
    end
  end
end
