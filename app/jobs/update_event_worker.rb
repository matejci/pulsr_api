class UpdateEventWorker < ActiveJob::Base
  queue_as :high_priority

  def perform data, city = nil
    if (event = Event.where(eventful_id: data['id']).first).present?
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
      name: 'UpdateEventWorker',
      data: {
        values: data
      },
      error: e.message
    }

    Failure.create data

    raise e
  end
end