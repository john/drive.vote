require "rails_helper"

RSpec.describe Admin::RideZonesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/admin/ride_zones").to route_to("admin/ride_zones#index")
    end

    it "routes to #new" do
      expect(get: "/admin/ride_zones/new").to route_to("admin/ride_zones#new")
    end

    it "routes to #show" do
      expect(get: "/admin/ride_zones/1").to route_to("admin/ride_zones#show", id: "1")
    end

    it "routes to #drivers" do
      expect(get: "/admin/ride_zones/1/drivers").to route_to("admin/ride_zones#drivers", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/ride_zones/1/edit").to route_to("admin/ride_zones#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/admin/ride_zones").to route_to("admin/ride_zones#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/ride_zones/1").to route_to("admin/ride_zones#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/ride_zones/1").to route_to("admin/ride_zones#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/ride_zones/1").to route_to("admin/ride_zones#destroy", id: "1")
    end

    it "routes post to #add_role" do
      expect(post: "/admin/ride_zones/1/add_role").to route_to("admin/ride_zones#add_role", id: "1")
    end

    it "does not route get to #add_role" do
      expect(get: "/admin/ride_zones/1/add_role").to_not route_to("admin/ride_zones#add_role", id: "1")
    end

    it "routes to delete #remove_role" do
      expect(delete: "/admin/ride_zones/1/remove_role").to route_to("admin/ride_zones#remove_role", id: "1")
    end

    it "does not route get to #remove_role" do
      expect(get: "/admin/ride_zones/1/remove_role").to_not route_to("admin/ride_zones#remove_role", id: "1")
    end

  end
end
