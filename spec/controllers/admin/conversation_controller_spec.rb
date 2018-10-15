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
    it "404s if not logged in" do
      post :close, params: {id: convo.to_param}
      expect(response.status).to eq(404)
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
  
  describe 'POST #blacklist_voter_phone' do
    it "404s if not logged in" do
      post :blacklist_voter_phone, params: {id: convo.to_param}
      expect(response.status).to eq(404)
    end

    context "as admin" do
      login_admin

      it 'assigns the requested conversation as @conversation' do
        post :blacklist_voter_phone, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end

      it 'associates a blacklisted_phone' do
        post :blacklist_voter_phone, params: {id: convo.to_param}
        expect(assigns(:conversation).blacklisted_phone.phone).to eq(convo.from_phone)
      end
    end
  end
  
  describe 'POST #unblacklist_voter_phone' do
    it "404s if not logged in" do
      post :unblacklist_voter_phone, params: {id: convo.to_param}
      expect(response.status).to eq(404)
    end

    context "as admin" do
      login_admin

      it 'assigns the requested conversation as @conversation' do
        post :unblacklist_voter_phone, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end
      
      it 'removes a blacklisted_phone' do
        post :blacklist_voter_phone, params: {id: convo.to_param}
        expect(assigns(:conversation).blacklisted_phone.phone).to eq(convo.from_phone)
        
        reloaded_convo = assigns(:conversation)
        reloaded_convo.reload
        post :unblacklist_voter_phone, params: {id: convo.to_param}
        expect(reloaded_convo.blacklisted_phone).to be_nil
      end
    end
  end

end
