require 'rails_helper'

RSpec.describe Role, type: :model do

  it { should belong_to(:resource) }
  it { should have_and_belong_to_many(:users) }

end
