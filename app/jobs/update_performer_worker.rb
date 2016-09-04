class UpdatePerformerWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(data, event = nil)
    if (performer = Performer.where(eventful_id: data['id']).first).present?
      performer.update_from_eventful(data)
    else
      Eventful::Performer.process!(data, event)
    end
  rescue Exception => e
    data = {
      name: 'UpdatePerformerWorker',
      data: {
        values: data
      },
      error: e.message
    }

    Failure.create data

    raise e
  end
end