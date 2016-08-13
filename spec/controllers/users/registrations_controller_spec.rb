require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #new" do
    it "assigns a new User as @user when no role specified" do
      get :new, params: {}
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to be_successful
    end

    it 'sets role param if a valid role' do
      get :new, params: {type: 'unassigned_driver'}
      user = assigns(:user)
      expect(user.user_type).to eq('unassigned_driver')
      expect(response).to be_successful
    end

    it 'does not set role param if a disallowed role' do
      get :new, params: {type: 'admin'}
      user = assigns(:user)
      #expect(user.user_type).to eq('driver')
      expect(response).to be_redirect
    end

    it 'does not set role param if a bogus role' do
      get :new, params: {type: 'bad_role'}
      user = assigns(:user)
      #expect(user.user_type).to eq('driver')
      expect(response).to be_redirect
    end
  end

end
