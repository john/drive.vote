require 'rails_helper'

RSpec.describe Admin::RidesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Ride. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:voter) { create :voter }

  let(:valid_attributes) {
    {
      name: 'A ride',
      voter_id: voter.id,
    }
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

  describe "POST #create" do
    it "redirects if not logged in" do
      post :create, params: {ride: valid_attributes}
      expect(Ride.all.length).to be(0)
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "accepts JSON with a single ride's info" do
        post :create, params: {ride: valid_attributes}
        expect(response).to have_http_status(:see_other)
        expect(response.headers['Location']).to match(/\/admin\/rides\/\d+/)
        expect(assigns(:ride)).to be_a(Ride)
      end
    end
  end

end
