require 'rails_helper'

RSpec.describe Ride, type: :model do

  it { should belong_to(:ride_zone) }
  it { should validate_presence_of(:owner_id) }

end
