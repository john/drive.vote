require 'rails_helper'

RSpec.describe Admin::SitesController, type: :controller do
  let(:user) { create :user }

  describe 'GET show' do
    it "redirects if not logged in" do
      get :show
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'exposes the current settings' do
        site = Site.instance
        get :show, params: {:id => user.to_param}
        expect(assigns(:site)).to eq(site)
      end
    end
  end

  describe 'GET edit' do
    it "redirects if not logged in" do
      get :edit
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'exposes the current settings' do
        site = Site.instance
        get :show, params: {:id => user.to_param}
        expect(assigns(:site)).to eq(site)
      end
    end
  end

  describe 'PUT update' do
    it "redirects if not logged in" do
      put :update, params: { update_location_interval: 75, waiting_rides_interval: 10 }
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it 'updates the settings' do
        site = Site.instance
        put :update, params: { site: { update_location_interval: 75, waiting_rides_interval: 10 }}
        site.reload
        expect(site.update_location_interval).to eq 75
        expect(site.waiting_rides_interval).to eq 10
      end
    end
  end
end
