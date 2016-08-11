require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  login_admin

  # This should return the minimal set of attributes required to create a valid
  # Ride. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {name: 'Joe Test User', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073328709', zip: '94118'}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RidesController. Be sure to keep this updated too.

  describe "GET index" do
    it "renders" do
      get :index, params: {}
      # expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET #index" do
    it "assigns all users as @users" do
      user = User.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:users)).to eq([user])
    end
  end



  describe "GET show" do
    it "assigns the requested user as @user" do
      user = User.create! valid_attributes
      get :show, params: {:id => user.to_param}
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      skip
      # user = User.create! valid_attributes
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



