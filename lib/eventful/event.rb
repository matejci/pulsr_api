class Eventful::Event
  attr_accessor :city, :event, :object

  class << self
    def process! event, city = nil
      new(event, city).create
    end

    def import_xml path
      parser = Saxerator.parser(File.new(path))

      parser.for_tag(:event).each do |event|
        event_data = EventfulClient.correct_time_values(event)
        EventWorker.perform_later(event_data)
      end
    end

    def update_xml path
      parser = Saxerator.parser(File.new(path))

      parser.for_tag(:event).each do |event|
        event_data = EventfulClient.correct_time_values(event)
        UpdateEventWorker.perform_later(event_data)
      end
    end

    def withdraw_xml path
      parser = Saxerator.parser(File.new(path))

      ids = []
      parser.for_tag(:event).each do |event|
        ids << event['id']
      end
      ids.in_groups_of(200, false) do |eventful_ids|
        Event.delete_all(eventful_id: eventful_ids)
      end
    end
  end

  def initialize event, city = nil
    @event = event
    @city = city
  end

  def create
    data = city.present? ? EventfulClient.event_details(event['id']) : event
    @object = ::Event.create_from_eventful(data, city)

    self
  end

  def get_event_details event_id
    EventfulClient.event_details(event_id)
  end

  def has_performers?
    event["performers"].present?
  end

  def has_venue?
    event["venue_id"].present?
  end

  def performers
    Eventful::Core.extract_performers(event)
  end

  def venue_id
    event["venue_id"]
  end
end