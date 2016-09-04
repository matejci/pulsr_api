require 'rails_helper'

describe Api::SessionsController, type: :controller, skip: true do
  describe "Get Registered" do
    context "when username and password are valid" do
      it "creates a new user" do
        expect {
          post :authentication, {email: "siddhant@sd2labs.com", password: "mypass"}
        }.to change(User, :count).by(1)
      end

      it "should be success" do
        post :authentication, {email: "siddhant@sd2labs.com", password: "mypass"}
        response.should_be_success
      end
    end
  end
end