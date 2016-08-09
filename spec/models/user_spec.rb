require 'rails_helper'

RSpec.describe User, :type => :model do

  it { should validate_presence_of :email }

  it 'returns driver ride zone' do
    rz = create :ride_zone
    u = create :driver_user, ride_zone: rz
    u.reload.driver_ride_zone_id.should == rz.id
  end

  it 'updates location timestamp for lat change' do
    u = create :user
    u.reload.location_updated_at.should be_nil
    u.update_attribute :latitude, 34
    u.reload.location_updated_at.should_not be_nil
  end

  it 'updates location timestamp for long change' do
    u = create :user
    u.update_attribute :longitude, -122
    u.reload.location_updated_at.should_not be_nil
  end
end
