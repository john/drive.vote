require 'rails_helper'

RSpec.describe RidesController, type: :routing do
  it 'routes to #new' do
    expect(get: '/get_a_ride/42').to route_to('rides#new', ride_zone_id: '42')
  end

  it 'routes to #create' do
    expect(post: '/rides').to route_to('rides#create')
  end

  it 'routes to #edit' do
    expect(get: '/rides/42/edit').to route_to('rides#edit', id: '42')
  end

  it 'routes to #update' do
    expect(put: '/rides/42').to route_to('rides#update', id: '42')
  end
end
