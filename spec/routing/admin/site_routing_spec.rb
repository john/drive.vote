require "rails_helper"

RSpec.describe Admin::SitesController, :type => :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "admin/site").to route_to("admin/sites#show")
    end

    it "routes to #edit" do
      expect(:get => "admin/site/edit").to route_to("admin/sites#edit")
    end

    it "routes to #update" do
      expect(:put => "admin/site").to route_to("admin/sites#update")
    end
  end
end
