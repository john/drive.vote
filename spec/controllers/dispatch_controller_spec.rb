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
