require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/volunteer_to_drive/1').to route_to('users/registrations#new', id: '1')
    end
  end
end
