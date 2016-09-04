require 'rails_helper'

RSpec.describe Api::TagsController, type: :controller do
	handle_authentication

	let(:event) { attributes_for(:event) }
	let(:tag) { attributes_for(:tag) }
	let!(:created_event) { Event.create!(event.merge({user_id: user.id})) }
	let!(:created_tag) { create(:tag) }

	describe 'GET list' do
		context 'with event params' do
			it "return success status" do
				xhr :get, :index, event_id: created_event
				expect(response.status).to eq(200)
			end

			it "return success true" do
				xhr :get, :index, event_id: created_event
				expect(json['success']).to be_truthy
			end

			it "returns event record" do
				created_event.tags << created_tag
				xhr :get, :index, event_id: created_event
				tags = json_data['tags'].map { |x| x['name'] }
				expect(tags).to include(created_tag[:name])
			end
		end
	end

	describe 'POST add' do
		context 'with valid event and tag params' do
			it 'should return success' do
				xhr :post, :add, id: created_tag.to_param, event_id: created_event.to_param
				expect(response.status).to eq(200)
			end

			it 'should return the status true' do
				xhr :post, :add, id: created_tag.to_param, event_id: created_event.to_param
				expect(json['status']).to be_truthy
			end

			it 'should increase the number of tags of the event by 1' do
				n = created_event.tags.count
				xhr :post, :add, id: created_tag.to_param, event_id: created_event.to_param
				expect(created_event.tags.count).to eq(n+1)
			end
		end
	end

	describe 'POST remove' do
		context 'with valid event and tag params' do
			it 'should return success' do
				created_event.tags << created_tag
				xhr :post, :remove, id: created_tag.to_param, event_id: created_event.to_param
				expect(response.status).to eq(200)
			end

			it 'should return the status true' do
				created_event.tags << created_tag
				xhr :post, :remove, id: created_tag.to_param, event_id: created_event.to_param
				expect(json['status']).to be_truthy
			end

			it 'should increase the number of tags of the event by 1' do
				created_event.tags << created_tag
				n = created_event.tags.count
				xhr :post, :remove, id: created_tag.to_param, event_id: created_event.to_param
				expect(created_event.tags.count).to eq(n-1)
			end
		end
	end

end
