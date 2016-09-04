require 'rails_helper'

RSpec.describe Api::VenuesController, type: :controller do
	handle_authentication

	let(:venue) { attributes_for(:venue) }
	let(:created_venue) { Venue.create!(venue) }
	let(:date_param) { 2.days.since.to_s }
	let(:incomplete_request_data) {
		{
				id: created_venue,
		}
	}
	let(:request_data) { incomplete_request_data.merge({date: date_param}) }

	describe 'Get Details' do
		context 'with valid date params' do
			it "return success status" do
				xhr :get, :show, request_data
				expect(response.status).to eq(200)
			end

			it "return success true" do
				xhr :get, :show, request_data
				expect(json['success']).to be_truthy
			end

			it "returns venue record with the same data" do
				xhr :get, :show, request_data
				expect(json_data['venue']['name']).to eq(created_venue.name)
			end
		end

		context 'without valid date params' do
			it "return status Unprocessable_Entity" do
				xhr :get, :show, incomplete_request_data
				expect(response.status).to eq(422)
			end

			it "return success false" do
				xhr :get, :show, incomplete_request_data
				expect(json['success']).to be_falsey
			end

		end
	end

	describe 'Get Hidden list' do
		context 'with valid params' do
			it "return success status" do
				created_venue.hidden_for_users << user
				xhr :get, :hidden, request_data
				expect(response.status).to eq(200)
			end

			it "return success true" do
				created_venue.hidden_for_users << user
				xhr :get, :hidden, request_data
				expect(json['success']).to be_truthy
			end

			it "returns venue record with the same data" do
				created_venue.hidden_for_users << user
				xhr :get, :hidden, request_data
				ids = json_data['users'].map { |x| x['id'] }

				expect(ids).to include(user.id)
			end
		end

	end

end
