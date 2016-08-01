require 'rails_helper'


RSpec.describe Admin::ElectionsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Campaign. As you add validations to Campaign, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CampaignsController. Be sure to keep this updated too.
  let(:valid_session) {
    controller.stub(:signed_in?).and_return(true)
    controller.stub(:require_admin_priviledges).and_return(true)
  }

#   describe "GET #index" do
#     it "assigns all campaigns as @campaigns" do
#       campaign = Campaign.create! valid_attributes
#       get :index, params: {}, session: valid_session
#       expect(assigns(:campaigns)).to eq([campaign])
#     end
#   end
#
#   describe "GET #show" do
#     it "assigns the requested campaign as @campaign" do
#       campaign = Campaign.create! valid_attributes
#       get :show, params: {id: campaign.to_param}, session: valid_session
#       expect(assigns(:campaign)).to eq(campaign)
#     end
#   end
#
#   describe "GET #new" do
#     it "assigns a new campaign as @campaign" do
#       get :new, params: {}, session: valid_session
#       expect(assigns(:campaign)).to be_a_new(Campaign)
#     end
#   end
#
#   describe "GET #edit" do
#     it "assigns the requested campaign as @campaign" do
#       campaign = Campaign.create! valid_attributes
#       get :edit, params: {id: campaign.to_param}, session: valid_session
#       expect(assigns(:campaign)).to eq(campaign)
#     end
#   end
#
#   describe "POST #create" do
#     context "with valid params" do
#       it "creates a new Campaign" do
#         expect {
#           post :create, params: {campaign: valid_attributes}, session: valid_session
#         }.to change(Campaign, :count).by(1)
#       end
#
#       it "assigns a newly created campaign as @campaign" do
#         post :create, params: {campaign: valid_attributes}, session: valid_session
#         expect(assigns(:campaign)).to be_a(Campaign)
#         expect(assigns(:campaign)).to be_persisted
#       end
#
#       it "redirects to the created campaign" do
#         post :create, params: {campaign: valid_attributes}, session: valid_session
#         expect(response).to redirect_to(Campaign.last)
#       end
#     end
#
#     context "with invalid params" do
#       it "assigns a newly created but unsaved campaign as @campaign" do
#         post :create, params: {campaign: invalid_attributes}, session: valid_session
#         expect(assigns(:campaign)).to be_a_new(Campaign)
#       end
#
#       it "re-renders the 'new' template" do
#         post :create, params: {campaign: invalid_attributes}, session: valid_session
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
#       it "updates the requested campaign" do
#         campaign = Campaign.create! valid_attributes
#         put :update, params: {id: campaign.to_param, campaign: new_attributes}, session: valid_session
#         campaign.reload
#         skip("Add assertions for updated state")
#       end
#
#       it "assigns the requested campaign as @campaign" do
#         campaign = Campaign.create! valid_attributes
#         put :update, params: {id: campaign.to_param, campaign: valid_attributes}, session: valid_session
#         expect(assigns(:campaign)).to eq(campaign)
#       end
#
#       it "redirects to the campaign" do
#         campaign = Campaign.create! valid_attributes
#         put :update, params: {id: campaign.to_param, campaign: valid_attributes}, session: valid_session
#         expect(response).to redirect_to(campaign)
#       end
#     end
#
#     context "with invalid params" do
#       it "assigns the campaign as @campaign" do
#         campaign = Campaign.create! valid_attributes
#         put :update, params: {id: campaign.to_param, campaign: invalid_attributes}, session: valid_session
#         expect(assigns(:campaign)).to eq(campaign)
#       end
#
#       it "re-renders the 'edit' template" do
#         campaign = Campaign.create! valid_attributes
#         put :update, params: {id: campaign.to_param, campaign: invalid_attributes}, session: valid_session
#         expect(response).to render_template("edit")
#       end
#     end
#   end
#
#   describe "DELETE #destroy" do
#     it "destroys the requested campaign" do
#       campaign = Campaign.create! valid_attributes
#       expect {
#         delete :destroy, params: {id: campaign.to_param}, session: valid_session
#       }.to change(Campaign, :count).by(-1)
#     end
#
#     it "redirects to the campaigns list" do
#       campaign = Campaign.create! valid_attributes
#       delete :destroy, params: {id: campaign.to_param}, session: valid_session
#       expect(response).to redirect_to(campaigns_url)
#     end
#   end

end
