require 'rails_helper'

RSpec.describe Admin::ConversationsController, type: :controller do
  login_admin

  let!(:rz) { create :ride_zone }
  let!(:convo) { create :conversation, ride_zone: rz }

  describe 'GET #index' do
    it 'assigns all non-closed as @conversations' do
      create(:closed_conversation, ride_zone: rz)
      get :index, params: {}
      expect(assigns(:conversations)).to eq([convo])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested conversation as @conversation' do
      get :show, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end
  end

  describe 'GET #messages' do
    it 'assigns the requested conversation as @conversation' do
      get :messages, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end
  end

  describe 'GET #form' do
    it 'assigns the requested conversation as @conversation' do
      get :form, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end
  end

  describe 'POST #update_attribute' do
    it 'assigns the requested conversation as @conversation' do
      get :update_attribute, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end
  end




  describe 'POST #close' do
    it 'assigns the requested conversation as @conversation' do
      post :close, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end

    it 'updates the conversation' do
      post :close, params: {id: convo.to_param}
      expect(convo.reload.status).to eq('closed')
    end
  end

end
