class Eventful::Venue
  attr_accessor :venue_id, :object, :event, :data

  class << self
    def process! venue, event = nil
      return if Venue.where("name like ? AND latitude = ? AND longitude = ?", venue['name'], venue['latitude'], venue['longitude']).any?
      new(venue, event).create
    end

    def import_xml path
      parser = Saxerator.parser(File.new(path))

      parser.for_tag(:venue).each do |venue|
        VenueWorker.perform_later(venue)
      end
    end

    def update_xml path
      parser = Saxerator.parser(File.new(path))

      parser.for_tag(:venue).each do |venue|
        UpdateVenueWorker.perform_later(venue)
      end
    end

  end

  def initialize venue, event = nil
    @event = event
    if venue.is_a?(Hash)
      @venue_id = venue['id']
      @data = venue
    else
      @venue_id = venue
    end
  end

  def create
    if (@object = ::Venue.where(eventful_id: venue_id).first).present?
      if event.present? && event.is_a?(Event)
        update_data = {
          venue: @object
        }

        if @object.latitude.present?
          update_data[:latitude] = @object.latitude
          update_data[:longitude] = @object.longitude
        end

        event.update_attributes update_data
      end
      # Update Venue if needed
      @object.update_from_eventful(data) if data.present?
    else
      @data = EventfulClient.venue_details(venue_id) unless data.present?

      @object = ::Venue.create_from_eventful(data, event)
    end

    self
  end

end