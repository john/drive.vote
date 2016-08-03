require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'lifecycle' do
    it 'detects language' do
      c = create :conversation
      c.send(:calculated_lifecycle).should == Conversation.lifecycles[:need_language]
    end

    it 'detects name' do
      c = create :conversation
      c.user.update_attributes language: 1, name: ''
      c.send(:calculated_lifecycle).should == Conversation.lifecycles[:need_name]
    end

    describe 'user attributes known' do
      let(:user) { create :user, language:1, name: 'foo' }
      it 'detects origin' do
        c = create :conversation, user: user
        c.send(:calculated_lifecycle).should == Conversation.lifecycles[:need_origin]
      end

      it 'detects destination' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6
        c.send(:calculated_lifecycle).should == Conversation.lifecycles[:need_destination]
      end

      it 'detects time' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6, to_latitude: 34.5, to_longitude: -122.6
        c.send(:calculated_lifecycle).should == Conversation.lifecycles[:need_time]
      end

      it 'detects complete' do
        c = create :complete_conversation, user: user
        c.send(:calculated_lifecycle).should == Conversation.lifecycles[:info_complete]
      end
    end
  end
end
