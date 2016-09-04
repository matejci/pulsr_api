class UpdateVenueWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(data, event = nil)
    if (venue = Venue.where(eventful_id: data['id']).first).present?
      venue.update_from_eventful(data)
    else
      Eventful::Venue.process!(data, event)
    end
  rescue Exception => e
    data = {
      name: 'UpdateVenueWorker',
      data: {
        values: data
      },
      error: e.message
    }

    Failure.create data

    raise e
  end
end