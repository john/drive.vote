require 'rails_helper'

RSpec.describe Message, type: :model do

  it { should belong_to(:conversation) }
  it { should belong_to(:ride_zone) }

  describe 'validations' do

    it { should validate_presence_of :conversation }

    describe 'conversation_has_correct_phone_numbers' do
      let(:convo) { create :conversation}
      let(:convo_with_messages) { create :conversation_with_messages}
      let(:message) { build :message }

      context 'Message is first message' do
        context 'convo to/from match' do
          it 'should be valid' do
            convo = create :conversation, to_phone: message.to, from_phone: message.from
            message.conversation = convo

            expect(message).to be_valid
          end
        end
      end

      context 'convo to/from do not match' do
        it 'should not be valid' do
          message.conversation = convo

          expect(message).to_not be_valid
        end
      end

      context 'Message is no first message' do
        it 'should be valid' do
          message.conversation = convo_with_messages

          expect(message).to be_valid
        end
      end
    end
  end

  describe 'event generation' do
    let!(:convo) { create :conversation_with_messages }

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
    convo = create :conversation_with_messages
    msg = create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone
    expect(msg.is_from_voter?).to be_truthy
  end
end
