require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  login_admin

  # This should return the minimal set of attributes required to create a valid
  # Ride. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {name: 'Joe Test User', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073328712', zip: ''}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET index" do
    it "assigns all users as @users" do
      User.create! valid_attributes # add a second user in addition to user logged in for testing
      users = User.all
      get :index, params: {}
      expect(assigns(:users)).to match_array(users)
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      user = User.create! valid_attributes
      get :show, params: {:id => user.to_param}
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      user = User.create! valid_attributes
      get :edit, params: {:id => user.to_param}
      expect(assigns(:user)).to eq(user)
    end
  end

end