require "rails_helper"

RSpec.describe Api::TagsController, type: :routing, skip: true do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/tags").to route_to("api/tags#index")
    end

    it "routes to #new" do
      expect(:get => "/api/tags/new").to route_to("api/tags#new")
    end

    it "routes to #show" do
      expect(:get => "/api/tags/1").to route_to("api/tags#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/tags/1/edit").to route_to("api/tags#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/tags").to route_to("api/tags#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/tags/1").to route_to("api/tags#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/tags/1").to route_to("api/tags#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/tags/1").to route_to("api/tags#destroy", :id => "1")
    end

  end
end
