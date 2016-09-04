class PerformerWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(data, event = nil)
    Eventful::Performer.process!(data, event)
  rescue Exception => e
    data = {
      name: 'PerformerWorker',
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