require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  login_user

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {name: 'Joe Test User', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073328710', zip: ''}
  }

  let(:invalid_attributes) {
    {name: 'Joe Test User', password: '12345abcde', phone_number: '2073328710', zip: ''}
  }

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

  describe "POST create" do
    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        post :create, params: {:user => invalid_attributes}
        expect(assigns(:user)).to be_a_new(User)
      end

      it "redirects to root" do
        post :create, params: {:user => invalid_attributes}
        expect(response).to redirect_to(:root)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        {name: '2Joe Test User2', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073325555', zip: ''}
      }

      it "updates the requested user" do
        user = User.create! valid_attributes

        expect(user.name).to eq('Joe Test User')
        put :update, params: {:id => user.to_param, :user => new_attributes}
        user.reload
        expect(user.name).to eq('2Joe Test User2')
      end

      it "assigns the requested user as @user" do
        user = User.create! valid_attributes
        put :update, params: {:id => user.to_param, :user => valid_attributes}
        expect(assigns(:user)).to eq(user)
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        put :update, params: {:id => user.to_param, :user => valid_attributes}
        expect(response).to redirect_to(root_path)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = User.create! valid_attributes
        put :update, params: {:id => user.to_param, :user => invalid_attributes}
        expect(assigns(:user)).to eq(user)
      end

      it "redirect to the root path" do
        user = User.create! valid_attributes
        put :update, params: {:id => user.to_param, :user => invalid_attributes}
        expect(response).to redirect_to(root_path)
      end
    end
  end

end