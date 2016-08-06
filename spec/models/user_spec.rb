require 'rails_helper'

RSpec.describe User, :type => :model do

  it { should validate_presence_of :email }

  it 'returns driver ride zone' do
    rz = create :ride_zone
    u = create :user
    u.add_role(:driver, rz)
    u.reload.driver_ride_zone_id.should == rz.id
  end
end
