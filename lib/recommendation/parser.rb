class Recommendation::Parser
  cattr_accessor :process_in_worker

  DAYS_TO_PARSE = 7

  class << self
    @@process_in_worker = true

    def process_cities
      City.with_boundaries.with_timezone.each do |city|
        if @@process_in_worker
          Recommendation::TasteCityWorker.perform_later(city)
        else
          process_city(city)
        end
      end
    end

    def process_city(city)
      Time.use_zone(city.timezone) do
        Taste.all.each do |taste|
          process_taste(taste, city)
        end
      end
    end

    def process_taste(taste, city)
      process_venues(taste, city)
      process_events(taste, city)
    end

    def process_venues(taste, city)
      Time.use_zone(city.timezone) do
        (1..Recommendation::Parser::DAYS_TO_PARSE).each do |increment|
          date = Time.now.beginning_of_day + increment.day

          if @@process_in_worker
            Recommendation::VenuesTasteCityWorker.perform_later(taste, city, date)
          else
            PointOfInterest.transaction do
              get_venues(taste, city, date).find_each do |venue|
                Recommendation::Parser.process_venue(venue, taste, city, date)
              end
            end
          end
        end
      end
    end

    def get_venues(taste, city, date, limit = 1000)
      taste.venues_by_zone(city).
            open_on_day(date).
            limit(limit)
    end

    def process_venue(venue, taste, city, date)
      poi = PointOfInterest.where(object_id: venue.id, object_type: "Venue", zone: city).for_date(date).first

      options = {
        starts_at: date
      }

      if poi.present?
        poi.taste_data[taste.id] = 1.0
        poi.save
      else
        poi = venue.to_pos(nil, options)
        poi.taste_data[taste.id] = 1.0
        poi.starts_at = date
        poi.save
      end
    end

    def process_events(taste, city)
      Time.use_zone(city.timezone) do
        (1..Recommendation::Parser::DAYS_TO_PARSE).each do |increment|
          PointOfInterest.transaction do
            date = Time.now.beginning_of_day + increment.day

            if @@process_in_worker
              Recommendation::EventsTasteCityWorker.perform_later(taste, city, date)
            else
              get_events(taste, city, date).find_each do |event|
                process_event(event, taste, city, date)
              end
            end
          end
        end
      end
    end

    def get_events(taste, city, date, limit = 1000)
      taste.events_by_zone(city).
            for_date(date).
            include_latest_timetable.
            limit(limit)
    end

    def process_event(event, taste, city, date)
      poi = PointOfInterest.where(object_id: event.id,
                                  object_type: "Event",
                                  zone: city).for_date(date).first

      options = {
        starts_at: date
      }

      if poi.present?
        poi.taste_data[taste.id] = 1.0
        poi.save
      else
        poi = event.to_pos(nil, options)
        poi.taste_data[taste.id] = 1.0
        poi.save
      end
    end
  end
end