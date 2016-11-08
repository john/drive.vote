require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #new" do
    context "for a ride zone" do
      let(:rz) { create :ride_zone }

      it "loads the ride zone specified" do
        get :new, params: {}
        expect(assigns(:user)).to be_a_new(User)
        expect(response).to be_successful
      end
    end

    it "redirects for a non-existent ride zone" do
      get :new, params: {id: 'blarg'}
      expect(response.status).to eq(404)
    end


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
      expect(response).to be_redirect
    end

    it 'does not set role param if a bogus role' do
      get :new, params: {type: 'bad_role'}
      user = assigns(:user)
      expect(response).to be_redirect
    end
  end

  describe "POST #create" do
    let(:rz) { create :ride_zone }
    let(:unassigned_driver) {
      {name: 'Joe Test User', email: 'foo@bar.com', password: '12345abcde', phone_number: '8133328712', zip: '', user_type: 'unassigned_driver', ride_zone_id: rz.id}
    }
    let(:voter) {
      {name: 'Joe Test User', email: 'foo@bar.com', password: '12345abcde', phone_number: '8133328712', zip: '', user_type: 'voter', ride_zone_id: rz.id}
    }

    it "creates a new unassigned driver for a specific ride zone" do
      expect { post :create, params: {user: unassigned_driver} }.to change(User, :count).by(1)
      expect(response).to be_redirect
      user_created = User.last
      expect( user_created.has_role?(:unassigned_driver, rz) ).to eq(true)
      expect( user_created.locale).to eq('en')
    end

    it "creates a new voter for a specific ride zone" do
      expect { post :create, params: {user: voter} }.to change(User, :count).by(1)
      expect(response).to be_redirect
      user_created = User.last
      expect( user_created.has_role?(:voter, rz) ).to eq(true)
    end
  end

end
