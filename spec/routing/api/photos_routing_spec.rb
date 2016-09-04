require "rails_helper"

RSpec.describe Api::PhotosController, type: :routing, skip: true do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/photos").to route_to("api/photos#index")
    end

    it "routes to #new" do
      expect(:get => "/api/photos/new").to route_to("api/photos#new")
    end

    it "routes to #show" do
      expect(:get => "/api/photos/1").to route_to("api/photos#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/photos/1/edit").to route_to("api/photos#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/photos").to route_to("api/photos#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/photos/1").to route_to("api/photos#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/photos/1").to route_to("api/photos#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/photos/1").to route_to("api/photos#destroy", :id => "1")
    end

  end
end
