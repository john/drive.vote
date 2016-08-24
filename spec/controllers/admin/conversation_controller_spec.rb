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

  describe 'GET #ride_pane' do
    it 'assigns the requested conversation as @conversation' do
      get :ride_pane, params: {id: convo.to_param}
      expect(assigns(:conversation)).to eq(convo)
    end

    it 'renders ride_form partial if convo does not have a ride' do
      get :ride_pane, params: {id: convo.to_param}
      expect(response).to render_template(partial: '_ride_form')
    end

    it 'renders ride_info partial if convo has a ride' do
      ride = create :ride
      convo.ride = ride
      convo.save
      get :ride_pane, params: {id: convo.to_param}
      expect(response).to render_template(partial: '_ride_info')
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
