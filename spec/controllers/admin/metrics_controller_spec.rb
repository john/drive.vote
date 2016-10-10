require 'rails_helper'

RSpec.describe Admin::MetricsController, type: :controller do

  describe "GET index" do
    it "redirects if not logged in" do
      get :index
      expect(response).to redirect_to('/404.html')
    end

    context "as admin" do
      login_admin

      it "assigns @voter_count" do
        voter = create :voter
        get :index
        expect(assigns(:voter_count)).to eq(1)
      end

      it "assigns @conversation_count" do
        conversation = create :conversation
        get :index
        expect(assigns(:conversation_count)).to eq(1)
      end

      it "assigns @ride_zone_count" do
        ride_zone = create :ride_zone
        get :index
        expect(assigns(:ride_zone_count)).to eq(1)
      end

      it "assigns @total_rides_count" do
        ride = create :ride
        get :index
        expect(assigns(:total_rides_count)).to eq(1)
      end

      it "assigns @total_rides_count" do
        ride = create :ride
        get :index
        expect(assigns(:total_rides_count)).to eq(1)
      end

      it "assigns @completed_rides_count" do
        ride = create :complete_ride
        get :index
        expect(assigns(:completed_rides_count)).to eq(1)
      end

      it "assigns @message_count" do
        create :conversation_with_messages

        get :index
        expect(assigns(:message_count)).to eq(2)
      end
    end
  end

end
