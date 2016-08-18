require 'rails_helper'

RSpec.describe DispatchController, :type => :controller do
  let(:dispatcher) { create(:dispatcher_user) }

  before :each do
    allow(controller).to receive(:signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(dispatcher)
  end

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET show" do
    it "returns http success" do
      rz = RideZone.with_role(:dispatcher, dispatcher).first
      get :show, params: {id: rz.id}
      expect(response).to have_http_status(:success)
    end
  end

end
