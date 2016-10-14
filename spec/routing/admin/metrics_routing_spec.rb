require 'rails_helper'

RSpec.describe Admin::MetricsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/metrics').to route_to('admin/metrics#index')
    end
  end
end
