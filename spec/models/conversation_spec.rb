require 'rails_helper'

RSpec.describe Conversation, type: :model do

  describe 'validations' do
    describe 'phone_numbers_match_first_message' do
      let(:convo) { create :conversation}

      context 'Conversation has no messages' do
        it 'should be valid' do
          expect(convo.messages.count).to eq(0)
          convo.to_phone = nil
          convo.from_phone = nil
          expect(convo).to be_valid
          end
      end

      context 'Conversation has messages' do
        context 'message to/from match' do
          it 'should be valid' do
            create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone
            create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone

            expect(convo).to be_valid
          end
        end
      end

      context 'message to/from do not match' do
        it 'should be valid' do
          create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone
          create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone

          convo.to_phone = '111-111-1111'
          convo.from_phone ='222-222-2222'

          expect(convo).to_not be_valid
        end
      end
    end
  end

  describe 'saving lifecycle' do
    let(:user) { create :user, language:1, name: 'foo' }
    it 'writes lifecycle to db' do
      c = create :conversation, user: user
      expect(c.reload.lifecycle).to eq('need_origin')
    end
  end

  describe 'event generation' do
    it 'sends new conversation event' do
      expect_any_instance_of(RideZone).to receive(:event).with(:new_conversation, anything)
      create :conversation
    end

    it 'sends conversation update event' do
      c = create :conversation
      expect_any_instance_of(RideZone).to receive(:event).with(:conversation_changed, anything)
      c.update_attribute(:status, :closed)
    end
  end

  it 'updates status on ride assignment' do
    r = create :ride
    c = create :conversation
    r.conversation = c
    expect(c.reload.status).to eq('ride_created')
  end

  describe 'lifecycle calculation' do
    it 'detects language' do
      c = create :conversation
      expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:need_language])
    end

    it 'detects name' do
      c = create :conversation
      c.user.update_attributes language: 1, name: ''
      expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:need_name])
    end

    describe 'user attributes known' do
      let(:user) { create :user, language:1, name: 'foo' }
      it 'detects origin' do
        c = create :conversation, user: user
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:need_origin])
      end

      it 'detects destination' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:need_destination])
      end

      it 'detects time' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6, to_latitude: 34.5, to_longitude: -122.6
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:need_time])
      end

      it 'detects complete' do
        c = create :complete_conversation, user: user
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:info_complete])
      end
    end
  end
end
