require 'rails_helper'

RSpec.describe User, :type => :model do

  it { should validate_presence_of :email }

  it 'returns driver ride zone' do
    rz = create :ride_zone
    u = create :driver_user, ride_zone: rz
    expect(u.reload.driver_ride_zone_id).to eq(rz.id)
  end

  it 'updates location timestamp for lat change' do
    u = create :user
    expect(u.reload.location_updated_at).to be_nil
    u.update_attribute :latitude, 34
    expect(u.reload.location_updated_at).to_not be_nil
  end

  it 'updates location timestamp for long change' do
    u = create :user
    u.update_attribute :longitude, -122
    expect(u.reload.location_updated_at).to_not be_nil
  end
end
