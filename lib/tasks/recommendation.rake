namespace :recommendation do
  desc "Zone the venues"
  task zone_venues: :environment do
    Recommendation::Zoner.zone_venues
  end
  desc "Zone the events"
  task zone_events: :environment do
    Recommendation::Zoner.zone_events
  end

  desc "Daily recommendation processing"
  task daily_processing: :environment do
    Recommendation::Parser.process_in_worker = false
    Recommendation::Parser.process_cities
  end

  desc "Clear old point of interests"
  task clear_old_data: :environment do
    PointOfInterest.clean_objects_until(7.days)
  end
end
