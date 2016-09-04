require "rails_helper"

describe Factual::DiffImporter, sql: true do
  let(:path) { Rails.root + 'db/factual_import/import.tab' }
  let(:diff_path) { Rails.root + 'db/factual_import/diff_import.tab' }
  let!(:importer) { Factual::Importer }

  let!(:category) { create(:category, id: 79) }
  let!(:category_2) { create(:category, id: 130) }
  let!(:new_category) { create(:category, id: 355) }

  before(:each) do
    stub_const("Factual::DiffImporter::DIRECTORY", Rails.root + "tmp/test/factual/diff_import/")
  end

  describe '.import_from_file' do
    before :each do
      stub_const("Factual::Importer::DIRECTORY", Rails.root + "tmp/test/factual/import1/")
      importer.import_from_file(path)
    end

    it 'changes to 4 venues' do
      expect {
        described_class.import_from_file(diff_path)
      }.to change {Venue.count}.from(5).to(4)
    end

    context "DELETE Venue" do
      let(:id) { "2ccc929e-49e5-4916-8144-15aa6357b92d" }

      it 'is created before diff import' do
        expect(find_by_factual_id(id)).to exist
      end

      it "removes the venue after diff import" do
        expect {
          described_class.import_from_file(diff_path)
        }.to change {
          find_by_factual_id(id).count
        }.by(-1)
      end

      it 'preserves old venue if contains eventful_id' do
        venue = find_by_factual_id(id).first
        venue.update_attribute :eventful_id, "eventful_id"

        described_class.import_from_file(diff_path)

        expect(find_by_factual_id(id)).to exist
        expect(find_by_factual_id(id).first.pending_at).not_to be_nil
      end
    end

    context "INSERT Venue" do
      let(:id) { "00286966-be0a-4104-b0a2-1ea671f4f319" }

      it "doesn't exist in original database" do
        expect(find_by_factual_id(id)).not_to exist
      end

      it 'creates venues from diff import' do
        described_class.import_from_file(diff_path)
        expect(find_by_factual_id(id)).to exist
      end
    end

    context "UPDATE Venue" do
      let(:id) { "decfa930-2695-4743-83fc-5b0d444f3913" }

      it 'has two categories before update' do
        categories = find_by_factual_id(id).first.categories

        expect(categories.count).to eq(2)
        expect(categories.map(&:id)).to include(category.id, category_2.id)
      end

      it 'changes the category of venue' do
        categories = find_by_factual_id(id).first.categories
        described_class.import_from_file(diff_path)
        new_categories = find_by_factual_id(id).first.categories
        expect(new_categories).not_to include(categories)
        expect(new_categories.count).to eq(2)
      end
    end

    context "MERGE Venue" do
      let(:id) { "2cdebfc4-6be1-4822-94e6-75844d89976d" }
      let(:new_id) { "2cd66137-fbff-442a-973a-e6f5ea224074" }

      it "has the both venues" do
        expect(find_by_factual_id(id)).to exist
        expect(find_by_factual_id(new_id)).to exist
      end

      it 'removes the old id' do
        described_class.import_from_file(diff_path)

        expect(find_by_factual_id(id)).not_to exist
        expect(find_by_factual_id(new_id)).to exist
      end
    end
  end
end