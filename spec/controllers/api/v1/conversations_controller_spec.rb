require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, :type => :controller, focus:true do

  describe 'get conversation' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation, ride_zone: rz, to_phone: rz.phone_number }
    let!(:msg1) { create :message, conversation: convo, ride_zone: rz }
    let!(:msg2) { create :message, conversation: convo, ride_zone: rz }

    it 'is successful' do
      get :show, params: {id: convo.id}
      expect(response).to be_successful
    end

    it 'returns conversation' do
      get :show, params: {id: convo.id}
      expect(JSON.parse(response.body)['response']).to eq(convo.api_json(true))
    end
  end

  describe 'create message' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation, ride_zone: rz }
    let(:body) { 'hello' }
    let(:twilio_msg) { OpenStruct.new(error_code: nil, status: 'delivered', body: body, sid: 'sid') }

    before :each do
      allow(TwilioService).to receive(:send_message).and_return(twilio_msg)
    end

    it 'is successful' do
      post :create_message, params: {id: convo.id, message: {body: body}}
      expect(response).to be_successful
    end

    it 'calls twilio service' do
      args = {from: convo.to_phone, to: convo.from_phone, body: body}
      expect(TwilioService).to receive(:send_message).with(args, Api::V1::ConversationsController::TWILIO_TIMEOUT)
      post :create_message, params: {id: convo.id, message: {body: body}}
    end

    it 'creates a message' do
      post :create_message, params: {id: convo.id, message: {body: body}}
      expect(Message.count).to eq(1)
      expect(Message.first.body).to eq(body)
      expect(Message.first.conversation_id).to eq(convo.id)
      expect(Message.first.ride_zone_id).to eq(rz.id)
    end

    it 'rejects missing message param' do
      post :create_message, params: {id: convo.id, message: {}}
      expect(response.status).to eq(400)
    end

    it 'rejects missing conversation' do
      post :create_message, params: {id: 0, message: {body: body}}
      expect(response.status).to eq(404)
    end
  end
end