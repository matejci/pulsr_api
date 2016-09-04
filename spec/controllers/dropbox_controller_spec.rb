require 'rails_helper'

RSpec.describe DropboxController, type: :controller do

  describe "GET #update" do
    it "returns http success" do
      get :update
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #confirm_token" do
    it "returns http success" do
      get :confirm_token
      expect(response).to have_http_status(:success)
    end
  end

end
