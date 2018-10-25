require 'rails_helper'

RSpec.describe PotentialRide, type: :model do
  it { should belong_to(:ride_zone) }
  it { should belong_to(:voter) }
  it { should belong_to(:ride_upload) }
  it { should validate_presence_of(:ride_zone) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:pickup_at) }
  it { should validate_presence_of(:from_address) }
  it { should validate_presence_of(:from_city) }
  it { should validate_presence_of(:status) }
end
