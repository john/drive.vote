require 'rails_helper'

RSpec.describe RideZone, type: :model do

  it { should have_many(:messages) }

end
