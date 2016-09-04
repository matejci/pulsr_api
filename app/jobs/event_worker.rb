class EventWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(data, city = nil)

    start_time = data['start_time'].nil? ? nil : data['start_time'].to_time.utc
    stop_time = data['stop_time'].nil? ? nil : data['stop_time'].to_time.utc

    if start_time.nil? && stop_time.nil?
      return if Event.where("starts_at IS NULL AND ends_at IS NULL AND name = ? AND eventful_venue_id = ?", data['title'], data['venue_id']).any?
    elsif start_time.nil?
      return if Event.where("starts_at IS NULL AND ends_at = ? AND name = ? AND eventful_venue_id = ?", stop_time, data['title'], data['venue_id']).any?
    elsif stop_time.nil?
      return if Event.where("starts_at = ? AND ends_at IS NULL AND name = ? AND eventful_venue_id = ?", start_time, data['title'], data['venue_id']).any?
    else
      return if Event.where("starts_at = ? AND ends_at = ? AND name = ? AND eventful_venue_id = ?", start_time, stop_time, data['title'], data['venue_id']).any?
    end

    if (event = Event.where(eventful_id: data['id']).first).present?
      # Updates for events
      event.update_from_eventful(data)
    else
      event = Eventful::Event.process!(data, city)

      if event.has_venue? && !event.object.venue_id.present?
        VenueWorker.perform_later(event.venue_id, event.object)
      end

      if event.has_performers?
        event.performers.each do |performer|
          PerformerWorker.perform_later(performer, event.object)
        end
      end
    end

    rescue Exception => e
      data = {
        name: 'EventWorker',
        data: {
          values: data,
          event: event.as_json
          },
          error: e.message
        }
        Failure.create data
    raise e
  end
end