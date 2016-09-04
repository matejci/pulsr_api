require 'rails_helper'

describe Api::SessionsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
	let(:json_data) { json['data'] }
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

	describe "POST authentication" do
		context "User registration" do
			describe "valid user information" do
        let(:request_data) { attributes_for(:user).merge({authentication_type: "signup"}) }

				it "creates a new user" do
					expect {
						xhr :post, :authentication, request_data
					}.to change(User, :count).by(1)
				end

				it "returns success" do
					xhr :post, :authentication, request_data
					expect(response.status).to eq(200)
				end

				it "created user has the same we created it with" do
					xhr :post, :authentication, request_data
					expect(json_data['user']['email']).to eq(request_data[:email])
				end
			end
		end

		context "Login with existing user" do
			describe "valid user login information" do
        let(:user_data) { attributes_for(:user) }
        let(:request_data) { user_data.merge({authentication_type: "login"}) }
        let!(:user) { User.create(user_data) }

				it "returns user's token" do
					xhr :post, :authentication, request_data
					expect(json_data['access_token']).to be_present
				end

				it "returns success" do
					xhr :post, :authentication, request_data
					expect(response.status).to eq(200)
				end
			end
		end

		context "Login with Facebook account" do
      let(:request_data) { { facebook_token: Faker::Internet.password } }
      let(:user_data) { attributes_for(:user) }

      before :each do
        allow_any_instance_of(FacebookClient).to receive(:personal_details).and_return({
          'email' => user_data[:email],
          'id' => Faker::Internet.password
        })
      end

      describe "register when username and password are valid" do
				it 'returns new token' do
          xhr :post, :authentication, request_data
					expect(json_data['access_token']).to be_present
				end
      end

      describe "register Facebook account for existing account" do
        let!(:user) { User.create(user_data) }

				it 'notifies the existance of user with that email' do
					xhr :post, :authentication, request_data
          expect(response.status).to eq(401)
				end

				it 'merges account and Facebook account' do
					xhr :post, :authentication, request_data.merge({password: user_data[:password]})
          expect(json_data['access_token']).to be_present
				end
			end
		end
	end
end
