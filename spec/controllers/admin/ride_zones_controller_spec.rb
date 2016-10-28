require 'rails_helper'

RSpec.describe Admin::RideZonesController, type: :controller do

  let(:valid_attributes) { { name: 'Toledo, OH', zip: '43601', phone_number: '203-867-5309', slug: 'toledo' } }
  let(:invalid_attributes) { skip("Add a hash of attributes invalid for your model") }
  let(:rz) { create :ride_zone }
  let(:rz2) { create :ride_zone, slug: 'rz2' }

  describe "GET #index" do
    it "redirects if not logged in" do
      get :index
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        get :index
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "shows you the rz you have rights to" do
        get :index, params: {}
        expect( assigns(:ride_zones).first).to eq(rz)
        expect( assigns(:ride_zones).collect(&:id)).to include(rz.id)
        expect( assigns(:ride_zones).length).to eq(1)
      end

      it "does not show you rz's you don't have rights to" do
        get :index, params: {}
        expect( assigns(:ride_zones).first).to eq(rz)
        expect( assigns(:ride_zones).collect(&:id)).to include(rz.id)
        expect( assigns(:ride_zones).length).to eq(1)
        expect( assigns(:ride_zones).collect(&:id)).not_to include(rz2.id)
      end
    end

    context "as super admin" do
      login_admin

      it "assigns all ride_zones as @ride_zones" do
        get :index, params: {}

        expect(assigns(:ride_zones)).to eq([rz, rz2])
        expect( assigns(:ride_zones).length).to eq(2)
        expect( assigns(:ride_zones).collect(&:id)).to include(rz.id)
        expect( assigns(:ride_zones).collect(&:id)).to include(rz2.id)
      end
    end
  end

  describe "GET #show" do
    it "redirects if not logged in" do
      get :show, params: {id: rz.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        get :show, params: {id: rz.to_param}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as admin" do
      login_admin

      it "assigns the requested ride_zone as @ride_zone" do
        get :show, params: {id: rz.to_param}
        expect(assigns(:ride_zone)).to eq(rz)
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "assigns the requested ride_zone as @ride_zone" do
        get :show, params: {id: rz.to_param}
        expect(assigns(:ride_zone)).to eq(rz)
      end
    end
  end

  describe "GET #new" do
    it "redirects if not logged in" do
      get :new
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        get :new
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "redirects single rz admins" do
        get :new
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as admin" do
      login_admin

      it "assigns a new ride_zone as @ride_zone" do
        get :new
        expect(assigns(:ride_zone)).to be_a_new(RideZone)
      end
    end
  end

  describe "GET #edit" do
    it "redirects if not logged in" do
      get :edit, params: {id: rz.to_param}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        get :edit, params: {id: rz.to_param}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "assigns the requested ride_zone as @ride_zone" do
        get :edit, params: {id: rz.to_param}
        expect(assigns(:ride_zone)).to eq(rz)
      end
    end

    context "as admin" do
      login_admin

      it "assigns the requested ride_zone as @ride_zone" do
        get :edit, params: {id: rz.to_param}
        expect(assigns(:ride_zone)).to eq(rz)
      end
    end
  end

  describe "POST #add_role" do
    it "redirects if not logged in" do
      user = create(:user)
      post :add_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        user = create(:user)
        post :add_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "adds a dispatcher to a ride zone" do
        user = create(:user)

        expect {
          post :add_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
        }.to change(rz.dispatchers, :count).by(1)
      end

      it "adds a driver to a ride zone" do
        user = create(:user)

        expect {
          post :add_role, params: {id: rz.to_param, user_id: user.to_param, role: 'driver'}
        }.to change{ rz.drivers.count(:all) }.by(1)
      end
    end

    context "as admin" do
      login_admin

      it "adds a dispatcher to a ride zone" do
        user = create(:user)

        expect {
          post :add_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
        }.to change(rz.dispatchers, :count).by(1)
      end

      it "adds a driver to a ride zone" do
        user = create(:user)

        expect {
          post :add_role, params: {id: rz.to_param, user_id: user.to_param, role: 'driver'}
        }.to change{ rz.drivers.count(:all) }.by(1)
      end
    end

    # We problably want to relax this. Remove after confirmed
    # it "only lets a user drive for one ride zone" do
    #   user = create(:user)
    #   ride_zone_1 = create(:ride_zone)
    #   ride_zone_2 = create(:ride_zone, name: 'rz2')
    #
    #   user.add_role(:driver, ride_zone_1)
    #
    #   expect {
    #     post :add_role, params: {id: ride_zone_2.to_param, user_id: user.to_param, role: 'driver'}
    #   }.to change(ride_zone_2.drivers, :count).by(0)
    # end
  end

  describe "POST #remove_role" do
    it "redirects if not logged in" do
      user = create(:user)
      user.add_role(:dispatcher, rz)
      delete :remove_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        user = create(:user)
        user.add_role(:dispatcher, rz)
        delete :remove_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "remove a dispatcher from a ride zone" do
        user = create(:user)
        user.add_role(:dispatcher, rz)

        expect {
          delete :remove_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
        }.to change(rz.dispatchers, :count).by(-1)
      end

      it "remove a driver from a ride zone" do
        user = create(:user)
        user.add_role(:driver, rz)

        expect {
          delete :remove_role, params: {id: rz.to_param, user_id: user.to_param, role: 'driver'}
        }.to change{ rz.drivers.count(:all) }.by(-1)
      end
    end

    context "as admin" do
      login_admin

      it "remove a dispatcher from a ride zone" do
        user = create(:user)
        user.add_role(:dispatcher, rz)

        expect {
          delete :remove_role, params: {id: rz.to_param, user_id: user.to_param, role: 'dispatcher'}
        }.to change(rz.dispatchers, :count).by(-1)
      end

      it "remove a driver from a ride zone" do
        user = create(:user)
        user.add_role(:driver, rz)

        expect {
          delete :remove_role, params: {id: rz.to_param, user_id: user.to_param, role: 'driver'}
        }.to change{ rz.drivers.count(:all) }.by(-1)
      end
    end
  end

  describe "POST #change_role" do
    it "redirects if not logged in" do
      user = create(:unassigned_driver_user)
      post :change_role, params: { id: rz.id, driver: user.id, to_role: 'driver' }
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        user = create(:unassigned_driver_user)
        post :change_role, params: { id: rz.id, driver: user.id, to_role: 'driver' }
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "can promote" do
        user = create(:unassigned_driver_user)
        expect {
          post :change_role, params: { id: rz.id, driver: user.id, to_role: 'driver' }
        }.to change{ rz.drivers.count(:all) }.by(1)
      end
    end

    context "as admin" do
      login_admin

      it "can promote" do
        user = create(:unassigned_driver_user)
        expect {
          post :change_role, params: { id: rz.id, driver: user.id, to_role: 'driver' }
        }.to change{ rz.drivers.count(:all) }.by(1)
      end

      # TODO: implement these once the fix to rolify is in place
      # context "handles both kinds of unassigned_driver roles" do
      #   it "removes a scoped unassigned_driver role" do
      #   end
      #
      #   it "removes unscoped unassigned_driver role" do
      #   end
      # end
    end
  end

  describe "POST #create" do
    it "redirects if not logged in" do
      post :create, params: {ride_zone: valid_attributes}
      expect(response).to redirect_to('/404.html')
    end

    context "as dispatcher" do
      login_dispatcher

      it "redirects dispatchers" do
        post :create, params: {ride_zone: valid_attributes}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "as single rz admin" do
      login_rz_admin

      it "redirects" do
        post :create, params: {ride_zone: valid_attributes}
        expect(response).to redirect_to('/404.html')
      end
    end

    context "admin with valid params" do
      login_admin

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
