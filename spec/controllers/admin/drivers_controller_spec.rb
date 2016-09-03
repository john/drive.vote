require 'rails_helper'

RSpec.describe Admin::DriversController, type: :controller do
  login_admin

  describe "GET #index" do
    it "assigns all drivers as @drivers" do
      driver = create :driver_user
      get :index, params: {all: 'please'}
      expect(assigns(:drivers)).to eq([driver])
    end
  end

end
