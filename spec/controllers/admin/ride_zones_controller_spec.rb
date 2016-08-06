require 'rails_helper'


RSpec.describe Admin::RideZonesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # RideZone. As you add validations to RideZone, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { slug: 'toledo_ohio', name: 'Toledo, OH', phone_number: '867-5309' }
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RideZonesController. Be sure to keep this updated too.
  let(:valid_session) {
    controller.stub(:signed_in?).and_return(true)
    controller.stub(:require_admin_privileges).and_return(true)
    controller.stub(:require_zone_privilege).and_return(true)
  }

  describe "GET #index" do
    it "assigns all ride_zones as @ride_zones" do
      ride_zone = create(:ride_zone)
      get :index, params: {}, session: valid_session
      expect(assigns(:ride_zones)).to eq([ride_zone])
    end
  end

  describe "GET #show" do
    it "assigns the requested ride_zone as @ride_zone" do
      ride_zone = create(:ride_zone)
      get :show, params: {id: ride_zone.to_param}, session: valid_session
      expect(assigns(:ride_zone)).to eq(ride_zone)
    end
  end

  describe "GET #new" do
    it "assigns a new ride_zone as @ride_zone" do
      get :new, params: {}, session: valid_session
      expect(assigns(:ride_zone)).to be_a_new(RideZone)
    end
  end

  describe "GET #edit" do
    it "assigns the requested ride_zone as @ride_zone" do
      ride_zone = create(:ride_zone)
      get :edit, params: {id: ride_zone.to_param}, session: valid_session
      expect(assigns(:ride_zone)).to eq(ride_zone)
    end
  end

  describe "GET #add_dispatcher" do
    it "does something" do
      user = create(:user)
      ride_zone = create(:ride_zone)

      # expect {
      #         delete :destroy, params: {id: ride_zone.to_param}, session: valid_session
      #       }.to change(RideZone, :count).by(-1)

      expect {
        get :add_dispatcher, params: {id: ride_zone.to_param, user_id: user.to_param}, session: valid_session
      }.to change(ride_zone.dispatchers, :count).by(1)
    end
  end

  describe "GET #add_driver" do
    it "does something" do
      user = create(:user)
      ride_zone = create(:ride_zone)

      expect {
        get :add_driver, params: {id: ride_zone.to_param, user_id: user.to_param}, session: valid_session
      }.to change(ride_zone.drivers, :count).by(1)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new RideZone" do
        expect {
          post :create, params: {ride_zone: valid_attributes}, session: valid_session
        }.to change(RideZone, :count).by(1)
      end

      it "assigns a newly created ride_zone as @ride_zone" do
        post :create, params: {ride_zone: valid_attributes}, session: valid_session
        expect(assigns(:ride_zone)).to be_a(RideZone)
        expect(assigns(:ride_zone)).to be_persisted
      end

      it "redirects to the created ride_zone" do
        post :create, params: {ride_zone: valid_attributes}, session: valid_session
        expect(response).to redirect_to( admin_ride_zones_path )
      end
    end

    # context "with invalid params" do
    #   it "assigns a newly created but unsaved ride_zone as @ride_zone" do
    #     post :create, params: {ride_zone: invalid_attributes}, session: valid_session
    #     expect(assigns(:ride_zone)).to be_a_new(RideZone)
    #   end
    #
    #   it "re-renders the 'new' template" do
    #     post :create, params: {ride_zone: invalid_attributes}, session: valid_session
    #     expect(response).to render_template("new")
    #   end
    # end
  end
#
#   describe "PUT #update" do
#     context "with valid params" do
#       let(:new_attributes) {
#         skip("Add a hash of attributes valid for your model")
#       }
#
#       it "updates the requested ride_zone" do
#         ride_zone = RideZone.create! valid_attributes
#         put :update, params: {id: ride_zone.to_param, ride_zone: new_attributes}, session: valid_session
#         ride_zone.reload
#         skip("Add assertions for updated state")
#       end
#
#       it "assigns the requested ride_zone as @ride_zone" do
#         ride_zone = RideZone.create! valid_attributes
#         put :update, params: {id: ride_zone.to_param, ride_zone: valid_attributes}, session: valid_session
#         expect(assigns(:ride_zone)).to eq(ride_zone)
#       end
#
#       it "redirects to the ride_zone" do
#         ride_zone = RideZone.create! valid_attributes
#         put :update, params: {id: ride_zone.to_param, ride_zone: valid_attributes}, session: valid_session
#         expect(response).to redirect_to(ride_zone)
#       end
#     end
#
#     context "with invalid params" do
#       it "assigns the ride_zone as @ride_zone" do
#         ride_zone = RideZone.create! valid_attributes
#         put :update, params: {id: ride_zone.to_param, ride_zone: invalid_attributes}, session: valid_session
#         expect(assigns(:ride_zone)).to eq(ride_zone)
#       end
#
#       it "re-renders the 'edit' template" do
#         ride_zone = RideZone.create! valid_attributes
#         put :update, params: {id: ride_zone.to_param, ride_zone: invalid_attributes}, session: valid_session
#         expect(response).to render_template("edit")
#       end
#     end
#   end
#
#   describe "DELETE #destroy" do
#     it "destroys the requested ride_zone" do
#       ride_zone = RideZone.create! valid_attributes
#       expect {
#         delete :destroy, params: {id: ride_zone.to_param}, session: valid_session
#       }.to change(RideZone, :count).by(-1)
#     end
#
#     it "redirects to the ride_zones list" do
#       ride_zone = RideZone.create! valid_attributes
#       delete :destroy, params: {id: ride_zone.to_param}, session: valid_session
#       expect(response).to redirect_to(ride_zones_url)
#     end
#   end

end
