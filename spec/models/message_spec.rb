require 'rails_helper'

RSpec.describe Message, type: :model do

  it { should belong_to(:conversation) }
  it { should belong_to(:ride_zone) }

  it 'reports is_from_voter' do
    rz = create :ride_zone
    convo = create :conversation, ride_zone: rz, to_phone: rz.phone_number
    msg = create :message, conversation: convo, ride_zone: rz
    msg.is_from_voter?.should be_truthy
  end
end
