require 'rails_helper'

RSpec.describe Admin::TwilioController, type: :controller do

  let(:valid_attributes) {
    skip('')
  }

  let(:invalid_attributes) {
    skip('')
  }

  describe 'POST sms' do
    let(:from_number) { '+12073328709' }
    let(:to_number) { '+14193860121' }
    let(:msg) { 'I need a ride' }
    let(:response_text) { 'On our way!' }
    let!(:ride_zone) { create :ride_zone, phone_number: to_number }
    let(:user) { create :user, phone_number: from_number }

    it 'works' do
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      expect(response).to be_successful
    end

    it 'creates user' do
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      User.last.phone_number.should == from_number
    end

    it 'creates message' do
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      Message.last.body.should eq msg
    end

    it 'creates conversation' do
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      Conversation.last.from_phone.should eq from_number
    end

    it 'reuses conversation' do
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      c = Conversation.last
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      Conversation.count.should == 1
      Message.last.conversation_id.should == c.id
    end

    it 'does not reuse closed conversation' do
      c = create :conversation, user: user, from_phone: from_number, ride_zone: ride_zone, status: Conversation.statuses[:closed]
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      Conversation.count.should == 2
      Message.last.conversation_id.should_not == c.id
    end

    it 'responds with bot response' do
      ConversationBot.any_instance.should_receive(:response) { response_text }
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      response.body.include?(response_text).should be_truthy
    end

    it 'handles bad to phone' do
      RideZone.stub(:find_by_phone_number) { nil }
      post :sms, params: {'From' => from_number, 'To' => to_number, 'Body' => msg}
      response.should be_successful  # we 200 back to Twilio
      response.body.include?(Admin::TwilioController::CONFIG_ERROR_MSG).should be_truthy
    end
  end

end



