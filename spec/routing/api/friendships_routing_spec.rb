require "rails_helper"

RSpec.describe Api::FriendshipsController, type: :routing, skip: true do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/friendships").to route_to("api/friendships#index")
    end

    it "routes to #new" do
      expect(:get => "/api/friendships/new").to route_to("api/friendships#new")
    end

    it "routes to #show" do
      expect(:get => "/api/friendships/1").to route_to("api/friendships#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/friendships/1/edit").to route_to("api/friendships#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/friendships").to route_to("api/friendships#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/friendships/1").to route_to("api/friendships#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/friendships/1").to route_to("api/friendships#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/friendships/1").to route_to("api/friendships#destroy", :id => "1")
    end

  end
end
