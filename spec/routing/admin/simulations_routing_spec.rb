require 'rails_helper'

RSpec.describe Admin::SimulationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/simulations').to route_to('admin/simulations#index')
    end

    it 'routes to #start_new' do
      expect(post: '/admin/simulations/start_new').to route_to('admin/simulations#start_new')
    end

    it 'routes to #clear_all_data' do
      expect(post: '/admin/simulations/clear_all_data').to route_to('admin/simulations#clear_all_data')
    end

    it 'routes to #stop' do
      expect(post: '/admin/simulations/1/stop').to route_to('admin/simulations#stop', id: '1')
    end

    it 'routes to #delete' do
      expect(delete: '/admin/simulations/1/delete').to route_to('admin/simulations#delete', id: '1')
    end
  end
end
