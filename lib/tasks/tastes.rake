namespace :tastes do
  desc "Import Tastes"
  task import: :environment do
    Tastes::Importer.process
	end

  desc "Import Tastes Photos"
  task import_photos: :environment do
    Tastes::Importer.import_photos
  end

  desc "Process Top Tastes by City"
  task process_by_city: :environment do
    City.update_top_tastes
  end
end