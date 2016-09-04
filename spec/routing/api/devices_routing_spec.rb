require "rails_helper"

RSpec.describe Api::DevicesController, type: :routing, skip: true do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/devices").to route_to("api/devices#index")
    end

    it "routes to #new" do
      expect(:get => "/api/devices/new").to route_to("api/devices#new")
    end

    it "routes to #show" do
      expect(:get => "/api/devices/1").to route_to("api/devices#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/devices/1/edit").to route_to("api/devices#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/devices").to route_to("api/devices#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/devices/1").to route_to("api/devices#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/devices/1").to route_to("api/devices#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/devices/1").to route_to("api/devices#destroy", :id => "1")
    end

  end
end
