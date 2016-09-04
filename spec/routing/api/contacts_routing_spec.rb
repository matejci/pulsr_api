require "rails_helper"

RSpec.describe Api::ContactsController, type: :routing, skip: true do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/contacts").to route_to("api/contacts#index")
    end

    it "routes to #new" do
      expect(:get => "/api/contacts/new").to route_to("api/contacts#new")
    end

    it "routes to #show" do
      expect(:get => "/api/contacts/1").to route_to("api/contacts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/contacts/1/edit").to route_to("api/contacts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/contacts").to route_to("api/contacts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/contacts/1").to route_to("api/contacts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/contacts/1").to route_to("api/contacts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/contacts/1").to route_to("api/contacts#destroy", :id => "1")
    end

  end
end
