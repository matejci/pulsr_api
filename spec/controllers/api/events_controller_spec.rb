require 'rails_helper'

RSpec.describe Api::EventsController, type: :controller do
	handle_authentication

	let(:venue) { attributes_for(:venue) }
	let(:created_venue) { Venue.create!(venue)}
	let(:event) { attributes_for(:event) }
	let(:event_data) do
		attributes_for(:event).merge({
			location: {
				venue_id: created_venue.id
			}
		})
	end
	let(:request_data) do
		{
			format: :json,
			event: event_data
		}
	end

	describe 'GET show' do
		let!(:created_event) { create(:event) }
		let(:starts_at) { created_event.timetables.last.starts_at }

		context 'with valid date params' do
			it "return success status" do
				xhr :get, :show, id: created_event, date: starts_at
				expect(response.status).to eq(200)
			end

			it "return success true" do
				xhr :get, :show, id: created_event, date: starts_at

				expect(json['success']).to be_truthy
			end

			it "returns event record with the same data" do
				xhr :get, :show, id: created_event, date: starts_at

				expect(json_data['event']['name']).to eq(created_event.name)
			end
		end

		context 'without valid date params' do
			it "return status Unprocessable_Entity" do
				xhr :get, :show, id: created_event

				expect(response.status).to eq(422)
			end

			it "return success false" do
				xhr :get, :show, id: created_event

				expect(json['success']).to be_falsey
			end

		end
	end

	describe "POST create" do
		context 'with valid event params' do
			it 'return success status' do
				xhr :post, :create, request_data

				expect(response.status).to eq(200)
			end

			it 'returns success true' do
				xhr :post, :create, request_data

				expect(json['success']).to be_truthy
			end

			it 'returns event data with same name' do
				xhr :post, :create, request_data

				expect(json_data['event']['name']).to eq(event_data[:name])
			end
		end

		context 'with invalid event params' do
			let(:invalid_request_data) {
				{
						format: :json,
						event: event
				}
			}
			it 'return failure status' do
				xhr :post, :create, invalid_request_data

				expect(response.status).to eq(422)
			end

			it 'returns success false' do
				xhr :post, :create, invalid_request_data

				expect(json['success']).to be_falsey
			end
		end

		describe 'with valid event and tags params' do
			let(:tag) { attributes_for(:tag) }

			before :each do
				request_data[:event].merge!({
					tags: [tag[:name]]
				})
			end

			context 'when tag exist' do
				before :each do
					create(:tag, tag)
				end

				it 'returns success status' do
					xhr :post, :create, request_data

					expect(response.status).to eq(200)
				end

				it 'returns attached tags to the event' do
					xhr :post, :create, request_data
					tags = json_data['event']['tags'].map { |x| x['name'] }

					expect(tags).to include(tag[:name])
				end
			end

			context 'when tag does not exist' do
				it 'returns success status' do
					xhr :post, :create, request_data

					expect(response.status).to eq(200)
				end

				it 'creates a new tag' do
					expect {
						xhr :post, :create, request_data
					}.to change(Tag, :count).by(1)
				end

				it 'returns the newly created tags to the event' do
					xhr :post, :create, request_data
					tags = json_data['event']['tags'].map { |x| x['name'] }

					expect(tags).to include(tag[:name])
				end
			end
		end
	end

	describe "PUT update" do
		let(:new_event) { attributes_for(:event) }
		let!(:created_event) { Event.create!(event.merge({user_id: user.id})) }
		let(:put_request_data) do
			{
					id: created_event.to_param,
					format: :json,
					event: new_event
			}
		end

		context 'with valid event params' do
			it 'return success status' do
				xhr :put, :update, put_request_data

				expect(response.status).to eq(200)
			end

			it 'returns success true' do
				xhr :put, :update, put_request_data

				expect(json['success']).to be_truthy
			end

			it 'returns event data with same name' do
				xhr :put, :update, put_request_data

				expect(json_data['event']['name']).to eq(new_event[:name])
			end
		end

		describe 'with valid event and tags params' do
			let(:tag) { attributes_for(:tag) }

			before :each do
				put_request_data[:event].merge!({
					tags: [tag[:name]]
				})
			end

			context 'when tag exist' do
				before :each do
					create(:tag, tag)
				end

				it 'returns success status' do
					xhr :put, :update, put_request_data

					expect(response.status).to eq(200)
				end

				it 'returns attached tags to the event' do
					xhr :put, :update, put_request_data
					tags = json_data['event']['tags'].map { |x| x['name'] }

					expect(tags).to include(tag[:name])
				end
			end

			context 'when tag does not exist' do
				it 'returns success status' do
					xhr :put, :update, put_request_data

					expect(response.status).to eq(200)
				end

				it 'creates a new tag' do
					expect {
						xhr :put, :update, put_request_data
					}.to change(Tag, :count).by(1)
				end

				it 'returns the newly created tags to the event' do
					xhr :put, :update, put_request_data
					tags = json_data['event']['tags'].map { |x| x['name'] }

					expect(tags).to include(tag[:name])
				end
			end
		end
	end

	describe "DELETE destroy" do
		let!(:created_event) { Event.create!(event.merge({user_id: user.id})) }

		it "deletes the event" do
			expect{
				xhr :delete, :destroy, id: created_event.to_param
			}.to change(Event,:count).by(-1)
		end
	end
end
