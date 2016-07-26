require 'rails_helper'


RSpec.describe MessagesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # RideArea. As you add validations to RideArea, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RideAreasController. Be sure to keep this updated too.
  let(:valid_session) { {} }

#   describe "GET #index" do
#     it "assigns all ride_areas as @ride_areas" do
#       ride_area = RideArea.create! valid_attributes
#       get :index, params: {}, session: valid_session
#       expect(assigns(:ride_areas)).to eq([ride_area])
#     end
#   end
#
#   describe "GET #show" do
#     it "assigns the requested ride_area as @ride_area" do
#       ride_area = RideArea.create! valid_attributes
#       get :show, params: {id: ride_area.to_param}, session: valid_session
#       expect(assigns(:ride_area)).to eq(ride_area)
#     end
#   end
#
#   describe "GET #new" do
#     it "assigns a new ride_area as @ride_area" do
#       get :new, params: {}, session: valid_session
#       expect(assigns(:ride_area)).to be_a_new(RideArea)
#     end
#   end
#
#   describe "GET #edit" do
#     it "assigns the requested ride_area as @ride_area" do
#       ride_area = RideArea.create! valid_attributes
#       get :edit, params: {id: ride_area.to_param}, session: valid_session
#       expect(assigns(:ride_area)).to eq(ride_area)
#     end
#   end
#
#   describe "POST #create" do
#     context "with valid params" do
#       it "creates a new RideArea" do
#         expect {
#           post :create, params: {ride_area: valid_attributes}, session: valid_session
#         }.to change(RideArea, :count).by(1)
#       end
#
#       it "assigns a newly created ride_area as @ride_area" do
#         post :create, params: {ride_area: valid_attributes}, session: valid_session
#         expect(assigns(:ride_area)).to be_a(RideArea)
#         expect(assigns(:ride_area)).to be_persisted
#       end
#
#       it "redirects to the created ride_area" do
#         post :create, params: {ride_area: valid_attributes}, session: valid_session
#         expect(response).to redirect_to(RideArea.last)
#       end
#     end
#
#     context "with invalid params" do
#       it "assigns a newly created but unsaved ride_area as @ride_area" do
#         post :create, params: {ride_area: invalid_attributes}, session: valid_session
#         expect(assigns(:ride_area)).to be_a_new(RideArea)
#       end
#
#       it "re-renders the 'new' template" do
#         post :create, params: {ride_area: invalid_attributes}, session: valid_session
#         expect(response).to render_template("new")
#       end
#     end
#   end
#
#   describe "PUT #update" do
#     context "with valid params" do
#       let(:new_attributes) {
#         skip("Add a hash of attributes valid for your model")
#       }
#
#       it "updates the requested ride_area" do
#         ride_area = RideArea.create! valid_attributes
#         put :update, params: {id: ride_area.to_param, ride_area: new_attributes}, session: valid_session
#         ride_area.reload
#         skip("Add assertions for updated state")
#       end
#
#       it "assigns the requested ride_area as @ride_area" do
#         ride_area = RideArea.create! valid_attributes
#         put :update, params: {id: ride_area.to_param, ride_area: valid_attributes}, session: valid_session
#         expect(assigns(:ride_area)).to eq(ride_area)
#       end
#
#       it "redirects to the ride_area" do
#         ride_area = RideArea.create! valid_attributes
#         put :update, params: {id: ride_area.to_param, ride_area: valid_attributes}, session: valid_session
#         expect(response).to redirect_to(ride_area)
#       end
#     end
#
#     context "with invalid params" do
#       it "assigns the ride_area as @ride_area" do
#         ride_area = RideArea.create! valid_attributes
#         put :update, params: {id: ride_area.to_param, ride_area: invalid_attributes}, session: valid_session
#         expect(assigns(:ride_area)).to eq(ride_area)
#       end
#
#       it "re-renders the 'edit' template" do
#         ride_area = RideArea.create! valid_attributes
#         put :update, params: {id: ride_area.to_param, ride_area: invalid_attributes}, session: valid_session
#         expect(response).to render_template("edit")
#       end
#     end
#   end
#
#   describe "DELETE #destroy" do
#     it "destroys the requested ride_area" do
#       ride_area = RideArea.create! valid_attributes
#       expect {
#         delete :destroy, params: {id: ride_area.to_param}, session: valid_session
#       }.to change(RideArea, :count).by(-1)
#     end
#
#     it "redirects to the ride_areas list" do
#       ride_area = RideArea.create! valid_attributes
#       delete :destroy, params: {id: ride_area.to_param}, session: valid_session
#       expect(response).to redirect_to(ride_areas_url)
#     end
#   end

end
