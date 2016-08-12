require 'rails_helper'

RSpec.describe Message, type: :model do

  it { should belong_to(:conversation) }
  it { should belong_to(:ride_zone) }

  describe 'event generation' do
    let!(:convo) { create :conversation }

    it 'sends new message event' do
      expect_any_instance_of(RideZone).to receive(:event).with(:new_message, anything)
      create :message, conversation: convo
    end

    it 'sends message update event' do
      m = create :message, conversation: convo
      expect_any_instance_of(RideZone).to receive(:event).with(:message_changed, anything)
      m.update_attribute(:sms_status, 'rejected')
    end
  end

  it 'reports is_from_voter' do
    rz = create :ride_zone
    convo = create :conversation, ride_zone: rz, to_phone: rz.phone_number
    msg = create :message, conversation: convo, ride_zone: rz
    expect(msg.is_from_voter?).to be_truthy
  end
end
