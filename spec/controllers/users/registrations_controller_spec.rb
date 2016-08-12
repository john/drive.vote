require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #new" do
    it "assigns a new User as @user" do
      get :new, params: {}
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to be_successful
    end
  end

  describe 'sets driver param' do
    it 'sets @user.user_type to type param' do
      get :new, params: {type: 'driver'}
      user = assigns(:user)
      expect(user.user_type).to eq('driver')
      expect(response).to be_successful
    end
  end

end
