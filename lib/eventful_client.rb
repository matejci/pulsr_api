require 'eventful/api'

class EventfulClient
  @@client = Eventful::API.new(ENV['EVENTFUL_API_KEY'])

  DEFAULT_PAGE_SIZE = 10
  DEFAULT_IMAGE_SIZE = 'blackborder500'

  class << self
    def correct_events_time!
      Event.upcoming
           .eventful_only
           .where(timezone_parse_at: nil)
           .select('DISTINCT ON (events.id) events.id')
           .find_each do |event|

        event = Event.find(event.id)

        update_time_for_event!(event)
      end
    end

    def correct_dst_for_events!
      Event.where.not(timezone_parse_at: nil).find_each do |event|
        event = Event.find(event.id)

        venue = event.venue

        if venue.present? && venue.zip_code.present?
          zip_code = venue.zip_code
          data = {}

          if event.starts_at.present?
            data[:starts_at] = autocorrect_dst_time(event.starts_at, zip_code)
          end

          if event.ends_at.present?
            data[:ends_at] = autocorrect_dst_time(event.ends_at, zip_code)
          end

          data[:timezone_parse_at] = Time.now

          event.update(data)

          event.timetables.each do |timetable|
            timetable_data = {}

            if timetable.starts_at.present?
              timetable_data[:starts_at] = autocorrect_dst_time(timetable.starts_at, zip_code)
            end

            if timetable.ends_at.present?
              timetable_data[:ends_at] = autocorrect_dst_time(timetable.ends_at, zip_code)
            end

            timetable.update(timetable_data)
          end
        end
      end
    end

    def update_time_for_event!(event)
      venue = event.venue

      if venue.present? && venue.zip_code.present?
        zip_code = venue.zip_code
        data = {}

        if event.starts_at.present?
          data[:starts_at] = autocorrect_time_by_zip_code(event.starts_at, zip_code)
        end

        if event.ends_at.present?
          data[:ends_at] = autocorrect_time_by_zip_code(event.ends_at, zip_code)
        end

        data[:timezone_parse_at] = Time.now

        event.update(data)

        event.timetables.each do |timetable|
          timetable_data = {}

          if timetable.starts_at.present?
            timetable_data[:starts_at] = autocorrect_time_by_zip_code(timetable.starts_at, zip_code)
          end

          if timetable.ends_at.present?
            timetable_data[:ends_at] = autocorrect_time_by_zip_code(timetable.ends_at, zip_code)
          end

          timetable.update(timetable_data)
        end
      end
    end

    def correct_time_values(event)
      olson_path = event['tz_olson_path']

      if olson_path.present?

        if event["start_time"].present?
          date = DateTime.parse(event["start_time"])
          event["start_time"] << get_offset_string(date, olson_path)
        end

        if event["stop_time"].present?
          date = DateTime.parse(event["stop_time"])
          event["stop_time"] << get_offset_string(date, olson_path)
        end

        if olson_path.present?
          recurrences = (['recurrence', 'instances', 'instance'].reduce(event) {|m,k| m && m[k] } || nil) || []
          recurrences = [recurrences] if recurrences.is_a?(Hash)

          recurrences.each do |recurrence|
            if recurrence['start_time'].present?
              date = DateTime.parse(recurrence['start_time'])
              recurrence['start_time'] << get_offset_string(date, olson_path)
            end

            if recurrence['stop_time'].present?
              date = DateTime.parse(recurrence['stop_time'])
              recurrence['stop_time'] << get_offset_string(date, olson_path)
            end
          end
        end
      end

      event
    end

    def autocorrect_time_by_zip_code(date, zip_code)
      offset = get_zip_code_offset(date, zip_code)

      date.to_datetime.change(offset: offset)
    end

    def autocorrect_time_by_olson_path(date, olson_path)
      offset = get_offset_string(date, olson_path)

      date.to_datetime.change(offset: offset)
    end

    def autocorrect_dst_time(date, zip_code)
      if date.dst?
        # Process only those within dst
        date - 1.hour
      else
        date
      end
    end

    def get_zip_code_offset(date, zip_code)
      time_zone = ActiveSupport::TimeZone.find_by_zipcode(zip_code)

      get_offset_string(time_zone)
    end

    def get_offset_string(date, olson_path)
      minutes = date.in_time_zone(olson_path).utc_offset/60
      result = ""

      if minutes < 0
        result << "-"
        minutes = minutes * -1
      else
        result << "+"
      end

      hours = minutes / 60
      minutes = minutes % 60

      result << (hours < 9 ? "0#{hours}" : hours)
      result << ":#{minutes < 9 ? '0' : '' }#{minutes}"
      result
    end

    def search options = {}
      options = options.reverse_merge({
        sort_order: 'popularity',
        page_size: DEFAULT_PAGE_SIZE,
        image_sizes: DEFAULT_IMAGE_SIZE
      })

      @@client.call 'events/search', options
    end

    def categories options = {}
      [].tap do |result|
        @@client.call('categories/list', options)["category"].each do |category|
          result << {
            id: category["id"],
            name: category["name"]
          }
        end
      end
    end

    def event_details event_id
      options = {
        id: event_id,
        image_sizes: DEFAULT_IMAGE_SIZE
      }

      @@client.call 'events/get', options
    end

    def performer_details performer_id
      options = {
        id: performer_id,
        image_sizes: DEFAULT_IMAGE_SIZE
      }

      @@client.call 'performers/get', options
    end

    def venue_details venue_id
      options = {
        id: venue_id,
        image_sizes: DEFAULT_IMAGE_SIZE
      }

      @@client.call 'venues/get', options
    end

    def search_by_location name, options = {}
      if name.is_a?(Hash)
        options = name.with_indifferent_access
        name = options[:name].present? ? options[:name] : "#{options[:latitude]}, #{options[:longitude]}"
      end

      query = {
        location: name
      }
      query[:within] = options[:radius]/1000 if options[:radius]
      query[:units] = 'km' if options[:radius]

      query[:date] = prepare_date(options) || 'Today'

      %i{count_only page_number}.each do |item|
        query[item] = options[item] if options[item]
      end

      query[:page_size] = options[:page_size] || DEFAULT_PAGE_SIZE


      if block_given?
        results = search(query)
        while results["page_number"].to_i <= results["page_count"].to_i
          if results["events"]
            if results["events"]["event"].is_a? Array
              results["events"]["event"].each { |event| yield(event, query) }
            else
              yield(results["events"]["event"], query)
            end
          end

          query[:page_number] = results["page_number"].to_i + 1
          results = search(query)
        end
      else
        search query
      end
    end

    def prepare_date data
      if [:from, :to].all? {|item| data[item].present? }
        data[:from] = Time.parse(data[:from]) if data[:from].is_a? String
        data[:to] = Time.parse(data[:to]) if data[:to].is_a? String

        "#{data[:from].strftime("%Y%m%d00")}-#{data[:to].strftime("%Y%m%d00")}"
      elsif data[:date]
        data[:date]
      end
    end

    def process_events_for name
      result = search_by_location name
    end

    def event_count_today_for name
      {}.tap do |result|
        categories.each do |category|
          options = {
            count_only: true,
            category: category.id
          }
          result[category.id] = search_by_location(city.name, options)["total_items"]
        end
      end
    end

    def event_count_today
      cities = City.all
      results = {}

      cities.each do |city|
        results[city.name] = search_by_location(city.name, {count_only: true})["total_items"]
      end

      results
    end
  end
end