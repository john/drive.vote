require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {name: 'Joe Test User', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073328712', zip: ''}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let!(:user) { create :dispatcher_user }

  describe "GET index" do
    it "redirects if not logged in" do
      get :index
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns all users as @users" do
        users = User.all
        get :index, params: {}
        expect(assigns(:users)).to match_array(users)
      end
    end
  end

  describe "GET show" do
    it "redirects if not logged in" do
      get :show, params: {:id => user.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns the requested user as @user" do
        user = User.create! valid_attributes
        get :show, params: {:id => user.to_param}
        expect(assigns(:user)).to eq(user)
      end
    end
  end

  describe "GET edit" do
    it "redirects if not logged in" do
      get :edit, params: {id: user.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns the requested user as @user" do
        user = User.create! valid_attributes
        get :edit, params: {:id => user.to_param}
        expect(assigns(:user)).to eq(user)
      end
    end
  end

  describe "PUT update" do
    let(:valid_new_attributes) {
      {name: '2Joe Test User2', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073325555', zip: ''}
    }

    it "redirects if not logged in" do
      put :update, params: {:id => user.to_param, :user => valid_new_attributes}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      describe "with valid params" do

        it "updates the requested user" do
          user_to_update = User.create! valid_attributes

          expect(user_to_update.name).to eq('Joe Test User')
          put :update, params: {:id => user_to_update.to_param, :user => valid_new_attributes}

          user_to_update.reload
          expect(user_to_update.name).to eq('2Joe Test User2')
        end
      end
    end
  end

  describe 'POST qa_clear' do
    it 'redirects if not logged in' do
      post :qa_clear, params: {:id => user.to_param }
      expect(response).to redirect_to('/404.html')
    end

    context 'as admin' do
      login_admin

      it 'calls clear' do
        expect_any_instance_of(User).to receive(:qa_clear)
        post :qa_clear, params: {:id => user.to_param}
      end
    end
  end

  describe 'DELETE destroy' do
    it 'redirects if not logged in' do
      delete :destroy, params: {:id => user.to_param }
      expect(response).to redirect_to('/404.html')
    end

    context 'as admin' do
      login_admin

      it 'calls clear' do
        expect_any_instance_of(User).to receive(:destroy)
        delete :destroy, params: {:id => user.to_param }
      end
    end
  end
end
