module AuthenticationHandler

	def handle_authentication
		let(:user) { create(:user) }
		let(:json) { JSON.parse(response.body) }
		let(:json_data) { json['data'] }

		before(:each) do
			@access_token = user.get_authentication_token
			request.headers['ACCESS-TOKEN'] = @access_token
		end
	end
end

RSpec.configure do |config|
  config.extend AuthenticationHandler, :type => :controller
end