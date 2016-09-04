require 'optparse'

namespace :eventful do |args|
  desc "Process events for next 5 days"
  task process_new_events: :environment do
    options = {
      from: Time.current,
      to: 5.day.since.in_time_zone(Time.zone).end_of_day
    }

    EventfulSubscriber.process_future_events options
  end

  desc "Weekly Import xml data from eventful remote api, works for monday full export"
  task weekly_import_api: :environment do
    Eventful::Importer::AllVenue.import
    Eventful::Importer::AllPerformer.import
    Eventful::Importer::AllEvent.import
  end

  desc "Import xml data from eventful remote api"
  task daily_import_api: :environment do
    Eventful::Importer::UpdateVenue.import
    Eventful::Importer::UpdatePerformer.import
    Eventful::Importer::UpdateEvent.import

    Eventful::Importer::WithdrawEvent.import
  end

  desc "Import Performers from XML"
  task import_performers_xml: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    filename = ARGV[1]

    if filename.present?
      Eventful::Performer.import_xml filename
    else
      puts "File path is missing. User rake eventful:import_performers_xml <file_path>"
    end
  end

  desc "Import Venues from XML"
  task import_venues_xml: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    filename = ARGV[1]

    if filename.present?
      Eventful::Venue.import_xml filename
    else
      puts "File path is missing. User rake eventful:import_venues_xml <file_path>"
    end
  end

  desc "Import Events from XML"
  task import_events_xml: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    filename = ARGV[1]

    if filename.present?
      Eventful::Event.import_xml filename
    else
      puts "File path is missing. User rake eventful:import_events_xml <file_path>"
    end
  end

  desc "Import Eventful from XML files"
  task import_events_xml: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    path = ARGV[1]
    pattern = ARGV[2]

    if path.present? && pattern.present?
      Eventful::Performer.import_xml "/Volumes/IVANT/pulsr_split-20150813-full-events.xml"
      Eventful::Venue.import_xml filename
      Eventful::Event.import_xml filename
    else
      puts "File path is missing. User rake eventful:import_events_xml <file_directory> <file_pattern>"
    end
  end

  desc "Remove pending venues if no upcoming events"
  task process_pending_venues: :environment do
    Venue.pending_deletion.each do |venue|
      if venue.events.upcoming.count > 0
        venue.update_attribute :pending_at, nil
      else
        venue.delete
      end
    end
  end
end