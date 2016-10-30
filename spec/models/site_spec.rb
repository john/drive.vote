require 'rails_helper'

RSpec.describe Site, :type => :model do
  it { should validate_inclusion_of(:update_location_interval).in_range(10..300) }
  it { should validate_inclusion_of(:waiting_rides_interval).in_range(10..300) }
  it { should validate_inclusion_of(:singleton_guard).in_array([0]) }
end
