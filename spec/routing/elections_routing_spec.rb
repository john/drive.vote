require "rails_helper"

RSpec.describe ElectionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/elections").to route_to("elections#index")
    end

    it "routes to #new" do
      expect(:get => "/elections/new").to route_to("elections#new")
    end

    it "routes to #show" do
      expect(:get => "/elections/1").to route_to("elections#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/elections/1/edit").to route_to("elections#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/elections").to route_to("elections#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/elections/1").to route_to("elections#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/elections/1").to route_to("elections#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/elections/1").to route_to("elections#destroy", :id => "1")
    end

  end
end
