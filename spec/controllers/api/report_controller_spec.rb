require 'rails_helper'

RSpec.describe Api::ReportController, type: :controller, skip: true do

  describe "GET #create" do
    it "returns http success" do
      get :create
      expect(response).to have_http_status(:success)
    end
  end

end
