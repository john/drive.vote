require 'rails_helper'

RSpec.describe DispatchController, :type => :controller do
  login_dispatcher

  describe "GET show" do
    it "returns http success" do
      rz = RideZone.with_role(:dispatcher, subject.current_user).first

      get :show, params: {id: rz.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET drivers" do
    it "returns http success" do
      rz = RideZone.with_role(:dispatcher, subject.current_user).first

      get :drivers, params: {id: rz.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET map" do
    it "returns http success" do
      rz = RideZone.with_role(:dispatcher, subject.current_user).first

      get :map, params: {id: rz.id}
      expect(response).to have_http_status(:success)
    end
  end
end
