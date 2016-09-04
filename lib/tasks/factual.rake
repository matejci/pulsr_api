require 'json'

namespace :factual do
  desc "Import Factual categories"
  task import_categories: :environment do
    file_name = Rails.root + 'db/factual_categories_taxonomy.json'
    file = File.read(file_name)
    data = JSON.parse(file)

    data.each do |category_id, item|
      values = {
        id: category_id,
        name: item["labels"]["en"],
        parent_id: item["parents"].first
      }
      Category.create values
    end

  end

  desc "Import full Factual venues data"
  task import_full_factual: :environment do
    url = Factual::Dropbox.places_file
    Factual::Importer.import_from_url(url)
  end

  desc "Import diff Factual venues data"
  task import_diff_factual: :environment do
    url = Factual::Dropbox.places_file
    Factual::DiffImporter.import_from_url(url)
  end

  desc "Import from local factual file"
  task import_local_file: :environment do
    Factual::DiffImporter.import_from_file('/home/deploy/factual_data/us_places.factual.v3_30.1435859403.tab')
  end
end
