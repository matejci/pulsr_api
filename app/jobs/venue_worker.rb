class VenueWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(data, event = nil)
    Eventful::Venue.process!(data, event)
  rescue Exception => e
    data = {
      name: 'VenueWorker',
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