require 'rails_helper'

RSpec.describe Api::ExploreController, type: :controller do
  handle_authentication

  let(:venue) { attributes_for(:venue) }
  let(:created_venue) { Venue.create!(venue) }
  let(:date_param) { 2.days.since.to_s }
  let(:incomplete_request_data) {
    {
        object_id: created_venue,
        object_type: 'Venue'
    }
  }
  let(:request_data) { incomplete_request_data.merge({date: date_param}) }

  describe 'POST Save' do
    context 'with valid date params' do
      let(:save_request_data) { request_data.merge({kind: 'save'}) }
      it "return success status" do
        xhr :post, :save, save_request_data
        expect(response.status).to eq(200)
      end

      it "return success true" do
        xhr :post, :save, save_request_data
        expect(json['status']).to be_truthy
      end
    end

    context 'without valid date params' do
      let(:save_request_data) { incomplete_request_data.merge({kind: 'save'}) }

      it "return status Unprocessable_Entity" do
        xhr :post, :save, save_request_data
        expect(response.status).to eq(422)
      end

      it "return success false" do
        xhr :post, :save, save_request_data
        expect(json['success']).to be_falsey
      end
    end
  end

  describe 'POST Remove' do
    context 'with valid date params' do
      let(:remove_request_data) { request_data.merge({kind: 'remove'}) }
      it "return success status" do
        xhr :post, :save, remove_request_data
        expect(response.status).to eq(200)
      end

      it "return success true" do
        xhr :post, :save, remove_request_data
        expect(json['status']).to be_truthy
      end
    end

    context 'without valid date params' do
      let(:remove_request_data) { incomplete_request_data.merge({kind: 'remove'}) }

      it "return status Unprocessable_Entity" do
        xhr :post, :save, remove_request_data
        expect(response.status).to eq(422)
      end

      it "return success false" do
        xhr :post, :save, remove_request_data
        expect(json['success']).to be_falsey
      end
    end
  end

  describe 'POST Hide' do
    context 'with valid date params' do
      let(:hide_request_data) { request_data.merge({kind: 'hide'}) }
      it "return success status" do
        xhr :post, :hide, hide_request_data
        expect(response.status).to eq(200)
      end

      it "return success true" do
        xhr :post, :hide, hide_request_data
        expect(json['status']).to be_truthy
      end
    end
  end

  describe 'POST Unhide' do
    context 'with valid date params' do
      let(:unhide_request_data) { request_data.merge({kind: 'unhide'}) }
      it "return success status" do
        xhr :post, :hide, unhide_request_data
        expect(response.status).to eq(200)
      end

      it "return success true" do
        xhr :post, :hide, unhide_request_data
        expect(json['status']).to be_truthy
      end
    end
  end

end
