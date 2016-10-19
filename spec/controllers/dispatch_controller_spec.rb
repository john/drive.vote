require 'rails_helper'

RSpec.describe DispatchController, :type => :controller do

  let(:rz) { create :ride_zone }

  describe "GET show" do
    it "redirects if not logged in" do
      get :show, params: {id: rz.id}
      expect(response).to redirect_to('/404.html')
    end

    context "as driver" do
      login_driver

      it "redirects" do
        get :show, params: {id: rz.id}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as dispatcher" do
      login_dispatcher

      it "succeeds" do
        get :show, params: {id: rz.id}
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #messages' do
    let!(:convo) { create :conversation, ride_zone: rz }

    it "redirects if not logged in" do
      get :messages, params: {id: convo.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'assigns the requested conversation as @conversation' do
        get :messages, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end
    end
  end

  describe 'GET #ride_pane' do
    let!(:convo) { create :conversation, ride_zone: rz }

    it "redirects if not logged in" do
      get :ride_pane, params: {id: convo.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'assigns the requested conversation as @conversation' do
        get :ride_pane, params: {id: convo.to_param}
        expect(assigns(:conversation)).to eq(convo)
      end

      it 'renders ride_form partial if convo does not have a ride' do
        get :ride_pane, params: {id: convo.to_param}
        expect(response).to render_template(partial: '_ride_form')
      end

      it 'renders ride_form partial if convo has a ride' do
        ride = create :ride
        convo.ride = ride
        convo.save
        get :ride_pane, params: {id: convo.to_param}
        expect(response).to render_template(partial: '_ride_form')
      end
    end
  end

  describe "GET drivers" do
    it "redirects if not logged in" do
      get :drivers, params: {id: rz.id}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "succeeds" do
        get :drivers, params: {id: rz.id}
        expect(response).to have_http_status(:success)
      end
    end

  end

  describe "GET map" do
    it "redirects if not logged in" do
      get :map, params: {id: rz.id}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher for different zone" do
      it "redirects" do
        different_rz_user = create( :user )
        ride_zone = create( :ride_zone )
        different_rz_user.add_role( :dispatcher, ride_zone)
        sign_in different_rz_user

        get :map, params: {id: rz.id}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as dispatcher" do
      login_dispatcher

      it "succeeds" do
        get :map, params: {id: rz.id}
        expect(response).to have_http_status(:success)
      end
    end

  end
end
