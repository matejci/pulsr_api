namespace :instagram do
  desc "Import Factual Instagram places"
  task import_places: :environment do
    url = Factual::Dropbox.instagram_file
    Instagram::Importer.import_from_url(url)
  end

  desc "Import missing instagram photos for venues"
  task import_missing_photos: :environment do
    offset = Venue.start_import_instagram_photos
  end

  desc "Import photos for new events"
  task process_event_photos: :environment do
    Event.update_instagram_photos
  end
end