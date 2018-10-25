require 'rails_helper'

RSpec.describe Admin::RideUploadsController, type: :controller do

  let(:valid_attributes) {
    {user: create(:user), ride_zone: create(:ride_zone), name: 'test ride upload name', csv: fixture_file_upload(Rails.root.join('spec', 'factories', 'files', 'test_ride_upload_valid.csv'), 'text/csv') }
  }

  # /admin/ride_zones/:ride_zone_id/ride_uploads
  describe "GET #index" do
    it "redirects if not logged in" do
      get :index, params: { ride_zone_id: 1}
      expect(response).to redirect_to('/404.html')
    end
    
    context "as admin" do
      login_admin
      
      it "assigns all ride_uploads as @ride_uploads" do
        ride_upload = RideUpload.create! valid_attributes
        
        get :index, params: { ride_zone_id: ride_upload.ride_zone.id }
        expect(assigns(:ride_uploads)).to eq([ride_upload])
      end
    end
  end

  describe "GET #show" do
    it "redirects if not logged in" do
      get :show, params: { ride_zone_id: 1, id: 1}
      expect(response).to redirect_to('/404.html')
    end
    
    context "as admin" do
      login_admin
      
      it "assigns the requested ride_upload as @ride_upload" do
        ride_upload = RideUpload.create! valid_attributes
        get :show, params: {ride_zone_id: ride_upload.ride_zone.id, id: ride_upload.to_param}
        expect(assigns(:ride_upload)).to eq(ride_upload)
      end
    end
  end

  # https://www.neontsunami.com/posts/testing-activestorage-uploads-in-rails-52
  describe "POST #create" do
    it "redirects if not logged in" do
      post :create, params: { ride_zone_id: 1, ride_upload: {} }
      expect(response).to redirect_to('/404.html')
    end
    
    context "as admin" do
      login_admin
      
      it "creates a new RideUpload from csv" do
        file = fixture_file_upload( Rails.root.join('spec', 'factories', 'files', 'test_ride_upload_valid.csv'), 'text/csv' )
        rz = create(:ride_zone)
        
        expect{
          post :create, params: {ride_zone_id: rz.id, ride_upload: {name: 'testup', csv: file }}
        }.to change(RideUpload, :count).by(1)
      end
      
      it "fails with non csv" do
        file = fixture_file_upload( Rails.root.join('spec', 'factories', 'files', 'isetta.jpeg'), 'image/jpeg' )
        rz = create(:ride_zone)
        
        expect{
          post :create, params: {ride_zone_id: rz.id, ride_upload: {name: 'testup', csv: file }}
        }.to change(RideUpload, :count).by(0)
      end

      # it "assigns a newly created scheduled_ride_upload as @scheduled_ride_upload" do
      #   post :create, params: {scheduled_ride_upload: valid_attributes}, session: valid_session
      #   expect(assigns(:scheduled_ride_upload)).to be_a(ScheduledRideUpload)
      #   expect(assigns(:scheduled_ride_upload)).to be_persisted
      # end
      #
      # it "redirects to the created scheduled_ride_upload" do
      #   post :create, params: {scheduled_ride_upload: valid_attributes}, session: valid_session
      #   expect(response).to redirect_to(ScheduledRideUpload.last)
      # end
    end

    # context "with invalid params" do
    #   it "assigns a newly created but unsaved scheduled_ride_upload as @scheduled_ride_upload" do
    #     post :create, params: {scheduled_ride_upload: invalid_attributes}, session: valid_session
    #     expect(assigns(:scheduled_ride_upload)).to be_a_new(ScheduledRideUpload)
    #   end
    #
    #   it "re-renders the 'new' template" do
    #     post :create, params: {scheduled_ride_upload: invalid_attributes}, session: valid_session
    #     expect(response).to render_template("new")
    #   end
    # end
  end
  
  # describe "GET #new" do
  #   it "assigns a new scheduled_ride_upload as @scheduled_ride_upload" do
  #     get :new, params: {}, session: valid_session
  #     expect(assigns(:scheduled_ride_upload)).to be_a_new(ScheduledRideUpload)
  #   end
  # end
  #
  # describe "GET #edit" do
  #   it "assigns the requested scheduled_ride_upload as @scheduled_ride_upload" do
  #     scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #     get :edit, params: {id: scheduled_ride_upload.to_param}, session: valid_session
  #     expect(assigns(:scheduled_ride_upload)).to eq(scheduled_ride_upload)
  #   end
  # end

  # describe "PUT #update" do
  #   context "with valid params" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }
  #
  #     it "updates the requested scheduled_ride_upload" do
  #       scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #       put :update, params: {id: scheduled_ride_upload.to_param, scheduled_ride_upload: new_attributes}, session: valid_session
  #       scheduled_ride_upload.reload
  #       skip("Add assertions for updated state")
  #     end
  #
  #     it "assigns the requested scheduled_ride_upload as @scheduled_ride_upload" do
  #       scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #       put :update, params: {id: scheduled_ride_upload.to_param, scheduled_ride_upload: valid_attributes}, session: valid_session
  #       expect(assigns(:scheduled_ride_upload)).to eq(scheduled_ride_upload)
  #     end
  #
  #     it "redirects to the scheduled_ride_upload" do
  #       scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #       put :update, params: {id: scheduled_ride_upload.to_param, scheduled_ride_upload: valid_attributes}, session: valid_session
  #       expect(response).to redirect_to(scheduled_ride_upload)
  #     end
  #   end
  #
  #   context "with invalid params" do
  #     it "assigns the scheduled_ride_upload as @scheduled_ride_upload" do
  #       scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #       put :update, params: {id: scheduled_ride_upload.to_param, scheduled_ride_upload: invalid_attributes}, session: valid_session
  #       expect(assigns(:scheduled_ride_upload)).to eq(scheduled_ride_upload)
  #     end
  #
  #     it "re-renders the 'edit' template" do
  #       scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #       put :update, params: {id: scheduled_ride_upload.to_param, scheduled_ride_upload: invalid_attributes}, session: valid_session
  #       expect(response).to render_template("edit")
  #     end
  #   end
  # end
  #
  # describe "DELETE #destroy" do
  #   it "destroys the requested scheduled_ride_upload" do
  #     scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #     expect {
  #       delete :destroy, params: {id: scheduled_ride_upload.to_param}, session: valid_session
  #     }.to change(ScheduledRideUpload, :count).by(-1)
  #   end
  #
  #   it "redirects to the scheduled_ride_uploads list" do
  #     scheduled_ride_upload = ScheduledRideUpload.create! valid_attributes
  #     delete :destroy, params: {id: scheduled_ride_upload.to_param}, session: valid_session
  #     expect(response).to redirect_to(scheduled_ride_uploads_url)
  #   end
  # end

end
