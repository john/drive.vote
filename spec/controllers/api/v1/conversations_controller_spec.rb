require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, :type => :controller do

  describe 'get conversation' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation_with_messages, ride_zone: rz}
    let!(:msg1) { convo.messages.first }
    let!(:msg2) { convo.messages.last }

    it "redirects if not logged in" do
      get :show, params: {id: convo.id}
      expect(response).to redirect_to('/404.html')
    end

    context "logged in as a voter" do
      login_voter

      it "redirects to 404" do
        get :show, params: {id: convo.id}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "logged in as a driver" do
      login_driver

      it 'is successful' do
        get :show, params: {id: convo.id}
        expect(response).to be_successful
      end

      it 'returns conversation' do
        get :show, params: {id: convo.id}
        expect(JSON.parse(response.body)['response']).to eq(convo.api_json(true))
      end
    end
  end

  describe 'POST #update_attribute' do
    let!(:rz) { create :ride_zone }
    let!(:convo) { create :conversation, ride_zone: rz }

    it "redirects if not logged in" do
      get :update_attribute, params: {id: convo.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "logged in as a voter" do
      login_voter

      it "redirects to 404" do
        post :update_attribute, params: {id: convo.to_param}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "logged in as a dispatcher" do
      login_dispatcher

      it 'assigns the requested conversation as @conversation' do
        post :update_attribute, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end

      it 'does the update' do
        post :update_attribute, params: {id: convo.to_param, name: 'from_address', value: 'foo'}
        expect(convo.reload.from_address).to eq('foo')
      end

      it 'updates conversation status to help_needed' do
        convo.update_attribute(:status, :in_progress)
        post :update_attribute, params: {id: convo.to_param, name: 'from_address', value: 'foo'}
        expect(convo.reload.status).to eq('help_needed')
      end
    end
  end

  describe 'POST #remove_help_needed' do
    let!(:rz) { create :ride_zone }
    let!(:convo) { create :complete_conversation, ride_zone: rz }
    let!(:ride) { Ride.create_from_conversation(convo) }

    before :each do
      convo.update_attributes(status: :help_needed)
    end

    it 'has right preconditions' do
      expect(convo.lifecycle).to eq('info_complete')
      expect(convo.status).to eq('help_needed')
    end

    it "redirects if not logged in" do
      post :remove_help_needed, params: {id: convo.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "logged in as a voter" do
      login_voter

      it "redirects to 404" do
        post :remove_help_needed, params: {id: convo.to_param}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "logged in as a dispatcher" do
      login_dispatcher

      it 'assigns the requested conversation as @conversation' do
        post :remove_help_needed, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end

      it 'does the status update' do
        post :remove_help_needed, params: {id: convo.to_param}
        expect(convo.reload.status).to eq('ride_created')
      end

      it 'does not update if no ride' do
        convo.update_attribute(:ride_id, nil)
        post :remove_help_needed, params: {id: convo.to_param}
        expect(response.status).to eq(400)
        expect(convo.reload.status).to eq('help_needed')
      end

      it 'does not update if not info_complete' do
        convo.update_attribute(:lifecycle, 'have_passengers')
        post :remove_help_needed, params: {id: convo.to_param}
        expect(response.status).to eq(400)
        expect(convo.reload.status).to eq('help_needed')
      end
    end
  end

  describe 'update conversation' do
    let(:rz) { create :ride_zone }
    let(:convo) { create :conversation_with_messages, ride_zone: rz}
    let!(:msg1) { convo.messages.first }
    let!(:msg2) { convo.messages.last }

    it "redirects if not logged in" do
      put :update, params: {id: convo.id, conversation: {from_address: 'foo'}}
      expect(response).to redirect_to('/404.html')
    end

    context "logged in as a voter" do
      login_voter

      it "redirects to 404" do
        put :update, params: {id: convo.id, conversation: {from_address: 'foo'}}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "logged in as a driver" do
      login_driver

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
        expect(JSON.parse(response.body)['response']).to eq(convo.reload.api_json(false).as_json)
      end
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

    it "redirects if not logged in" do
      post :create_message, params: {id: convo.id, message: {body: body}}
      expect(response).to redirect_to('/404.html')
    end

    context "logged in as a voter" do
      login_voter

      it "redirects to 404" do
        post :create_message, params: {id: convo.id, message: {body: body}}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "logged in as a driver" do
      login_driver

      it 'is successful' do
        post :create_message, params: {id: convo.id, message: {body: body}}
        expect(response).to be_successful
      end

      it 'calls twilio service' do
        args = {from: convo.ride_zone.phone_number_normalized, to: convo.user.phone_number, body: body}
        expect(TwilioService).to receive(:send_message).with(args, Rails.configuration.twilio_timeout)
        post :create_message, params: {id: convo.id, message: {body: body}}
      end

      it 'handles twilio service error' do
        args = {from: convo.ride_zone.phone_number_normalized, to: convo.user.phone_number, body: body}
        expect(TwilioService).to receive(:send_message).with(args, Rails.configuration.twilio_timeout) { raise "foobar" }
        post :create_message, params: {id: convo.id, message: {body: body}}
        expect(response.status).to eq(500)
        expect(response.body.include?('foobar')).to be_truthy
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
end
