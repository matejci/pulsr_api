require "rails_helper"

describe Factual::Importer do
  let(:path) { Rails.root + 'db/factual_import/import.tab' }
  let!(:category) { create(:category, id: 409) }

  before(:each) do
    stub_const("Factual::Importer::DIRECTORY", Rails.root + "tmp/test/factual/import/")
  end

  describe '.import_from_file' do
    before do
      described_class.import_from_file(path)
    end

    it 'creates 5 new venues' do
      expect(Venue.count).to eq(5)
    end

    context "Psi Marine venue" do
      let(:venue) { Venue.find_by(factual_id: "2cdebfc4-6be1-4822-94e6-75844d89976d") }

      it 'has been created' do
        expect(venue).not_to be_nil
      end

      it 'has a category' do
        expect(venue.categories.count).to eq(1)
      end

      it "has no opening hours defined" do
        expect(venue.hours).to eq(nil)
      end
    end

    context "Foothills Federal Credit Union" do
      let(:venue) { Venue.find_by(factual_id: "2cb8a5a5-a9ac-4fb9-bf4f-d7e240c2f089") }
      let(:hours) do
        {
          "friday"=>[["8:00", "17:00"]],
          "monday"=>[["8:00", "17:00"]],
          "tuesday"=>[["8:00", "17:00"]],
          "thursday"=>[["8:00", "17:00"]],
          "wednesday"=>[["8:00", "17:00"]]
        }
      end

      it 'has been created' do
        expect(venue).not_to be_nil
      end

      it 'has a category' do
        expect(venue.categories.count).to eq(0)
      end

      it "has no opening hours defined" do
        expect(venue.hours).to eq(hours)
      end
    end
  end
end