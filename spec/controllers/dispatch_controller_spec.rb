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
    let!(:convo) { create :complete_conversation, ride_zone: rz }

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

      it 'renders _form partial if convo does not have a ride' do
        get :ride_pane, params: {id: convo.to_param}
        expect(response).to render_template(partial: '_form')
      end

      describe 'with ride' do
        before :each do
          ride = Ride.create_from_conversation(convo)
          convo.ride = ride
          convo.save
        end

        it 'renders _form partial if convo has a ride' do
          get :ride_pane, params: {id: convo.to_param}
          expect(response).to render_template(partial: '_form')
        end

        it 'returns nearby sorted drivers' do
          d1 = create :driver_user, available: true, rz: convo.ride_zone
          d1.update_attributes(latitude: convo.from_latitude+0.2, longitude: convo.from_longitude+0.2)
          d2 = create :driver_user, available: true, rz: convo.ride_zone
          d2.update_attributes(latitude: convo.from_latitude+0.1, longitude: convo.from_longitude+0.1)
          d3 = create :driver_user, available: true, rz: convo.ride_zone
          d3.update_attributes(latitude: convo.from_latitude+0.15, longitude: convo.from_longitude+0.15)
          get :ride_pane, params: {id: convo.to_param}
          expect(assigns(:available_drivers_with_distance)[0][0].id).to eq(d2.id)
          expect(assigns(:available_drivers_with_distance)[1][0].id).to eq(d3.id)
          expect(assigns(:available_drivers_with_distance)[2][0].id).to eq(d1.id)
        end
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
