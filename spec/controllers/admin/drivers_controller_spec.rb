require 'rails_helper'

RSpec.describe Admin::DriversController, type: :controller do

  describe "GET index" do
    it "redirects if not logged in" do
      get :index
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns all drivers as @drivers" do
        driver = create :driver_user
        get :index, params: {all: 'please'}
        expect(assigns(:drivers)).to eq([driver])
      end
    end
  end

  describe "toggle driver availability" do

    context 'as admin' do
      login_admin

      it 'makes available driver unavailable' do
        driver = create :driver_user
        expect(driver.available).to be false  # verify default

        post :toggle_available, params: {:id => driver.to_param}

        driver.reload
        expect(driver.available).to be true
      end

      it 'makes unavailable driver available' do
        driver = create :driver_user
        expect(driver.available).to be false # verify default

        post :toggle_available, params: {:id => driver.to_param}
        driver.reload
        expect(driver.available).to be true # toggle once

        post :toggle_available, params: {:id => driver.to_param}
        driver.reload
        expect(driver.available).to be false # toggle again
      end

    end
  end

end
