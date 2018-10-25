require "rails_helper"

RSpec.describe Admin::RideUploadsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/ride_zones/1/ride_uploads").to route_to("admin/ride_uploads#index", :ride_zone_id => "1")
    end

    it "routes to #new" do
      expect(:get => "/admin/ride_zones/1/ride_uploads/new").to route_to("admin/ride_uploads#new", :ride_zone_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/admin/ride_zones/1/ride_uploads/1").to route_to("admin/ride_uploads#show", :ride_zone_id => "1", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin/ride_zones/1/ride_uploads/1/edit").to route_to("admin/ride_uploads#edit", :ride_zone_id => "1", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/ride_zones/1/ride_uploads").to route_to("admin/ride_uploads#create", :ride_zone_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/admin/ride_zones/1/ride_uploads/1").to route_to("admin/ride_uploads#update", :ride_zone_id => "1", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/admin/ride_zones/1/ride_uploads/1").to route_to("admin/ride_uploads#update", :ride_zone_id => "1", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/admin/ride_zones/1/ride_uploads/1").to route_to("admin/ride_uploads#destroy", :ride_zone_id => "1", :id => "1")
    end

  end
end
