require 'rails_helper'

RSpec.describe Api::PostsController, type: :controller do
	handle_authentication

	let(:event) { attributes_for(:event) }
	let(:event_post) { attributes_for(:post) }
	let!(:created_event) { create(:event) }
	let(:request_data) {
		{
				format: :json,
				post: event_post,
				event_id: created_event.to_param
		}
	}

	describe 'POST add' do
		context 'with valid event and post params' do
			it 'should return success' do
				xhr :post, :create, request_data
						expect(response).to have_http_status(:success)
			end

			it 'should return the status true' do
				xhr :post, :create, request_data
				expect(json['success']).to be_truthy
			end

			it 'should increase the number of posts of the event by 1' do
				n = created_event.posts.count
				xhr :post, :create, request_data
				expect(created_event.posts.count).to eq(n+1)
			end
		end
	end
end
