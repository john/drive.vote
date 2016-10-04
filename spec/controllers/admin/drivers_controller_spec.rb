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

end
