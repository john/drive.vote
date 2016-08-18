require 'rails_helper'

RSpec.describe DispatchController, :type => :controller do
  login_dispatcher

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET show" do
    it "returns http success" do

      # with just this, fails, can't find dispatcher_user from login_dispatcher macro
      #rz = RideZone.with_role(:dispatcher, dispatcher_user).first

      # fails, can't find current_user
      # rz = RideZone.with_role(:dispatcher, current_user).first


      # with jus this allows the rz to be gotten successfully, but the spec fails (it redirects rather than success,)
      # because current_user.has_role?(:dispatcher, @ride_zone) fails in ensure_ride_zone
      dispatcher_user = create( :dispatcher_user )
      rz = RideZone.with_role(:dispatcher, dispatcher_user).first

      # stubbing current_user allows ensure_ride_zone to return true, spec passes
      allow(controller).to receive(:current_user).and_return(dispatcher_user)

      get :show, params: {id: rz.id}
      expect(response).to have_http_status(:success)
    end
  end

end
