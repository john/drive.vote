require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, :type => :controller, focus:true do

  describe 'get conversation' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation, ride_zone: rz, to_phone: rz.phone_number }
    let!(:msg1) { create :message, conversation: convo, ride_zone: rz }
    let!(:msg2) { create :message, conversation: convo, ride_zone: rz }

    it 'is successful' do
      get :show, params: {id: convo.id}
      response.should be_successful
    end

    it 'returns conversation' do
      get :show, params: {id: convo.id}
      JSON.parse(response.body)['response'].should == convo.api_json(true)
    end
  end

  describe 'create message' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation, ride_zone: rz }
    let(:body) { 'hello' }
    let(:twilio_msg) { OpenStruct.new(error_code: nil, status: 'delivered', body: body, sid: 'sid') }

    before :each do
      TwilioService.stub(:send_message) { twilio_msg }
    end

    it 'is successful' do
      post :create_message, params: {id: convo.id, message: {body: body}}
      response.should be_successful
    end

    it 'calls twilio service' do
      args = [convo.to_phone, convo.from_phone, body, nil, Api::V1::ConversationsController::TWILIO_TIMEOUT]
      TwilioService.should_receive(:send_message).with(*args)
      post :create_message, params: {id: convo.id, message: {body: body}}
      Message.count.should == 1
      Message.first.body.should == body
    end

    it 'creates a message' do
      post :create_message, params: {id: convo.id, message: {body: body}}
      Message.count.should == 1
      Message.first.body.should == body
      Message.first.conversation_id.should == convo.id
      Message.first.ride_zone_id.should == rz.id
    end

    it 'rejects missing message param' do
      post :create_message, params: {id: convo.id, message: {}}
      response.status.should == 400
    end

    it 'rejects missing conversation' do
      post :create_message, params: {id: 0, message: {body: body}}
      response.status.should == 404
    end
  end
end
