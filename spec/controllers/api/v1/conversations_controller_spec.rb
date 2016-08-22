require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, :type => :controller do

  describe 'get conversation' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation_with_messages, ride_zone: rz}
    let!(:msg1) { convo.messages.first }
    let!(:msg2) { convo.messages.last }

    it 'is successful' do
      get :show, params: {id: convo.id}
      expect(response).to be_successful
    end

    it 'returns conversation' do
      get :show, params: {id: convo.id}
      expect(JSON.parse(response.body)['response']).to eq(convo.api_json(true))
    end
  end

  describe 'POST #update_attribute' do
    let!(:rz) { create :ride_zone }
    let!(:convo) { create :conversation, ride_zone: rz }

    it 'assigns the requested conversation as @conversation' do
      get :update_attribute, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end
  end

  describe 'update conversation' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation_with_messages, ride_zone: rz}
    let!(:msg1) { convo.messages.first }
    let!(:msg2) { convo.messages.last }

    it 'is successful' do
      put :update, params: {id: convo.id, conversation: {from_address: 'foo'}}
      expect(response).to be_successful
    end

    it 'updates conversation' do
      put :update, params: {id: convo.id, conversation: {from_address: 'foo'}}
      expect(convo.reload.from_address).to eq('foo')
    end

    it 'updates user name' do
      put :update, params: {id: convo.id, conversation: {name: 'foo'}}
      expect(convo.user.reload.name).to eq('foo')
    end

    it 'returns conversation' do
      put :update, params: {id: convo.id, conversation: {from_address: 'foo'}}
      expect(JSON.parse(response.body)['response']).to eq(convo.reload.api_json(false))
    end
  end

  describe 'create message' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation_with_messages, ride_zone: rz }
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
      convo.valid? # let(...) are lazy loaded, so make sure convo object is ready
      original_message_count = Message.count
      post :create_message, params: {id: convo.id, message: {body: body}}
      expect(Message.count).to eq(original_message_count + 1)
      expect(Message.last.body).to eq(body)
      expect(Message.last.conversation_id).to eq(convo.id)
      expect(Message.last.ride_zone_id).to eq(rz.id)
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
