require 'rails_helper'

RSpec.describe Admin::ConversationsController, type: :controller do
  let!(:rz) { create :ride_zone }
  let!(:convo) { create :conversation, ride_zone: rz }

  describe "GET index" do
    it "redirects if not logged in" do
      get :index
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'assigns all non-closed as @conversations' do
        get :index, params: {}
        expect(assigns(:conversations)).to match_array([convo])
      end
    end
  end

  describe 'GET #show' do

    it "redirects if not logged in" do
      get :show, params: {id: convo.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'assigns the requested conversation as @conversation' do
        get :show, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end
    end
  end

  describe 'POST #close' do
    it "redirects if not logged in" do
      post :close, params: {id: convo.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

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

end
