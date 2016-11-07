require 'rails_helper'

RSpec.describe Admin::RidesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Ride. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {voter_id: 1, name: 'foo', description: 'bar'}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:ride) { create :scheduled_ride }

  describe "GET index" do
    it "redirects if not logged in" do
      get :index
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns all rides as @rides" do
        ride = create :ride
        get :index, params: {}
        expect(assigns(:rides)).to eq([ride])
      end
    end
  end

  describe "GET #show" do
    it "redirects if not logged in" do
      get :show, params: {id: ride.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns the requested ride as @ride" do
        get :show, params: {id: ride.to_param}
        expect(assigns(:ride)).to eq(ride)
      end
    end
  end

  describe "GET #new" do
    it "redirects if not logged in" do
      get :new
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns a new ride as @ride" do
        get :new
        expect(assigns(:ride)).to be_a_new(Ride)
      end
    end
  end

  describe "GET #edit" do
    it "redirects if not logged in" do
      get :edit, params: {id: ride.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns the requested ride as @ride" do
        get :edit, params: {id: ride.to_param}
        expect(assigns(:ride)).to eq(ride)
      end
    end
  end

  describe "GET #create" do
    it "redirects if not logged in" do
      post :create, params: {id: ride.to_param}
      expect(response).to redirect_to('/404.html')
    end
  end

end
