require 'rails_helper'

RSpec.describe Api::SearchesController, type: :controller do
  handle_authentication

  after(:each) { SearchIndex.delete }

  before(:each) do
    create(:event, name: "Some event for query", latitude: 50, longitude: 20)
    create(:venue, name: "Some venue for query", latitude: 50, longitude: 20)
    SearchIndex.import!
  end

  describe "GET #show" do
    context "without automplete" do
      it "returns http success" do
        get :show, query: "query"
        expect(response).to have_http_status(:success)
      end

      it "returns results" do
        get :show, query: "query"
        expect(json_data['events'].count).to eq(1)
        expect(json_data['venues'].count).to eq(1)
      end

      it "returns results within location" do
        get :show, query: "query", latitude: 50, longitude: 20
        expect(json_data['events'].count).to eq(1)
        expect(json_data['venues'].count).to eq(1)
      end

      it "doesn't return results from different location" do
        get :show, query: "query", latitude: 40, longitude: 20
        expect(json_data['events'].count).to eq(0)
        expect(json_data['venues'].count).to eq(0)
      end
    end

    context "with automplete" do
      it "returns http success" do
        get :show, query: "que", automplete: true
        expect(response).to have_http_status(:success)
      end

      it "returns results" do
        get :show, query: "que", autocomplete: true
        expect(json_data.count).to eq(2)
      end

      it "returns results within location" do
        get :show, query: "que", latitude: 50, longitude: 20, autocomplete: true
        expect(json_data.count).to eq(2)
      end

      it "doesn't return results from different location" do
        get :show, query: "que", latitude: 40, longitude: 20, autocomplete: true
        expect(json_data.count).to eq(0)
      end
    end
  end
end
