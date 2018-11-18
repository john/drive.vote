require 'rails_helper'

RSpec.describe RidesController, type: :controller do

  describe 'GET #new' do
    it 'assigns a new ride as @ride' do
      rz = create(:ride_zone)
      get :new, params: {ride_zone_id: rz.id}
      expect(assigns(:ride)).to be_a_new(Ride)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested ride as @ride' do
      user = create :voter_user
      sign_in user
      ride = create :ride, voter: user, ride_zone: user.ride_zone
      get :edit, params: {id: ride.to_param}
      expect(assigns(:ride)).to eq(ride)
    end

    it 'redirects if not signed in' do
      user = create :voter_user
      ride = create :ride, voter: user, ride_zone: user.ride_zone
      get :edit, params: {id: ride.to_param}
      expect(response).to redirect_to('/users/sign_in')
    end
  end

  describe "GET #create" do
    let(:rz) { create :ride_zone }

    let(:good_data) { {"ride_zone_id"=>rz.id, "ride"=>
        { "name"=>"Gob",
          "from_address"=>"541 Carothers Ave",
          "from_city_state"=>"Carnegie, PA",
          "from_city"=>"Carnegie", "from_state"=>"PA", "pickup_at(1i)"=>"2016", "pickup_at(2i)"=>"11", "pickup_at(3i)"=>"8",
          "pickup_at(4i)"=>"05", "pickup_at(5i)"=>"00", "phone_number"=>"2083328765"}} }

    let(:bad_data) { {"ride_zone_id"=>rz.id, "ride"=>
        { "name"=>"Gob",
          "from_address"=>"330 Cabrillo St.",
          "from_city_state"=>"Carnegie, areallylonginvalidstringareallylonginvalidstringareallylonginvalidstring",
          "from_city"=>"Carnegie", "from_state"=>"areallylonginvalidstring",
          "pickup_at(1i)"=>"2016", "pickup_at(2i)"=>"11", "pickup_at(3i)"=>"8",
          "pickup_at(4i)"=>"05", "pickup_at(5i)"=>"00", "phone_number"=>"2083328765"}} }

    it "creates a user given good good data" do
      expect {
        post :create, params: good_data
      }.to change{ User.count }.by(1)
    end

    it "creates a ride given good data" do
      expect {
        post :create, params: good_data
      }.to change{ Ride.count }.by(1)
    end

    it "does not create a user given bad data" do
      expect {
        post :create, params: bad_data
      }.to change{ User.count }.by(0)
    end

    it "does not create a ride given bad data" do
      expect {
        post :create, params: bad_data
      }.to change{ Ride.count }.by(0)
    end
  end

  describe "PUT update" do
    let!(:ride) { create :scheduled_ride }
    let(:new_attributes) {
      { name: "Gob",
        to_address: "541 Carothers Ave",
        from_city_state: "Carnegie, PA",
        from_city: "Carnegie",
        from_state: "PA",
        phone_number: "2083328765"}
    }

    it "redirects if not logged in" do
      put :update, params: {:id => ride.to_param, :ride => new_attributes}
      expect(response).to be_redirect
    end


    context "as admin" do
      login_admin

      describe "with valid params" do
        it "updates the requsted ride" do
          ride_to_update = create :scheduled_ride
          Conversation.create_from_ride(ride_to_update, "Thanks")
          expect(ride_to_update.to_address).to eq("123 Main")
          put :update, params: {dispatcher: 'true', id: ride_to_update.to_param, ride: new_attributes}
          ride_to_update.reload
          expect(ride_to_update.to_address).to eq("541 Carothers Ave")
        end
      end
    end
  end

end
