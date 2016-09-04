class Instagram::EventWorker < ActiveJob::Base
  queue_as RateLimiter::INSTAGRAM_QUEUE

  def perform(event)
    event.update_instagram_photos
  rescue Exception => e
    data = {
      name: 'Instagram::EventWorker',
      data: {
        event: event
      },
      error: e.message
    }
    Failure.create data

    raise e
  end
end