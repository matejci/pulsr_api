require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller, skip: true do

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #saved" do
    it "returns http success" do
      get :saved
      expect(response).to have_http_status(:success)
    end
  end

end
