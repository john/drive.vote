require 'rails_helper'

RSpec.describe Admin::RideZonesController, type: :controller do
  login_admin

  # This should return the minimal set of attributes required to create a valid
  # RideZone. As you add validations to RideZone, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { slug: 'toledo_ohio', name: 'Toledo, OH', zip: '43601', phone_number: '867-5309' }
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET #index" do
    it "assigns all ride_zones as @ride_zones" do
      ride_zone = create(:ride_zone)
      get :index, params: {}
      expect(assigns(:ride_zones)).to eq([ride_zone])
    end
  end

  describe "GET #show" do
    it "assigns the requested ride_zone as @ride_zone" do
      ride_zone = create(:ride_zone)
      get :show, params: {id: ride_zone.to_param}
      expect(assigns(:ride_zone)).to eq(ride_zone)
    end
  end

  describe "GET #new" do
    it "assigns a new ride_zone as @ride_zone" do
      get :new, params: {}
      expect(assigns(:ride_zone)).to be_a_new(RideZone)
    end
  end

  describe "GET #edit" do
    it "assigns the requested ride_zone as @ride_zone" do
      ride_zone = create(:ride_zone)
      get :edit, params: {id: ride_zone.to_param}
      expect(assigns(:ride_zone)).to eq(ride_zone)
    end
  end

  describe "POST #add_dispatcher" do
    it "adds a dispatcher to a ride zone" do
      user = create(:user)
      ride_zone = create(:ride_zone)

      expect {
        post :add_dispatcher, params: {id: ride_zone.to_param, user_id: user.to_param}
      }.to change(ride_zone.dispatchers, :count).by(1)
    end
  end

  describe "POST #remove_dispatcher" do
    it "remove a dispatcher from a ride zone" do
      user = create(:user)
      ride_zone = create(:ride_zone)
      user.add_role(:dispatcher, ride_zone)

      expect {
        delete :remove_dispatcher, params: {id: ride_zone.to_param, user_id: user.to_param}
      }.to change(ride_zone.dispatchers, :count).by(-1)
    end
  end

  describe "POST #add_driver" do
    it "adds a driver to a ride zone" do
      user = create(:user)
      ride_zone = create(:ride_zone)

      expect {
        post :add_driver, params: {id: ride_zone.to_param, user_id: user.to_param}
      }.to change(ride_zone.drivers, :count).by(1)
    end

    it "only lets a user drive for one ride zone" do
      user = create(:user)
      ride_zone_1 = create(:ride_zone)
      ride_zone_2 = create(:ride_zone, name: 'rz2', slug: 'rz2')

      user.add_role(:driver, ride_zone_1)

      expect {
        post :add_driver, params: {id: ride_zone_2.to_param, user_id: user.to_param}
      }.to change(ride_zone_2.drivers, :count).by(0)
    end
  end

  describe "POST #remove_driver" do
    it "remove a driver from a ride zone" do
      user = create(:user)
      ride_zone = create(:ride_zone)
      user.add_role(:driver, ride_zone)

      expect {
        delete :remove_driver, params: {id: ride_zone.to_param, user_id: user.to_param}
      }.to change(ride_zone.drivers, :count).by(-1)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new RideZone" do
        expect {
          post :create, params: {ride_zone: valid_attributes}
        }.to change(RideZone, :count).by(1)
      end

      it "assigns a newly created ride_zone as @ride_zone" do
        post :create, params: {ride_zone: valid_attributes}
        expect(assigns(:ride_zone)).to be_a(RideZone)
        expect(assigns(:ride_zone)).to be_persisted
      end

      it "redirects to the created ride_zone" do
        post :create, params: {ride_zone: valid_attributes}
        expect(response).to redirect_to( admin_ride_zones_path )
      end
    end

  end

end
