require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Ride. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {name: 'foo', description: 'bar'}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RidesController. Be sure to keep this updated too.
  let(:valid_session) {
    controller.stub(:signed_in?).and_return(true)
    controller.stub(:require_admin_priviledges).and_return(true)
  }

  describe "GET index" do
    it "works" do
      get :index, {}, valid_session
      # expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      skip
      # user = User.create! valid_attributes
      # expect {
      #   delete :destroy, {:id => user.to_param}, valid_session
      # }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      skip
      # user = User.create! valid_attributes
      # delete :destroy, {:id => user.to_param}, valid_session
      # expect(response).to redirect_to(users_url)
    end
  end

end



