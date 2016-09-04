class Twitter::PerformerWorker < ActiveJob::Base
  queue_as RateLimiter::SEARCH_TWITTER_QUEUE

  def perform(performer)
    performer.update_twitter_username
  rescue Exception => e
    data = {
      name: 'Twitter::PerformerWorker',
      data: {
        performer: performer
      },
      error: e.message
    }

    Failure.create data

    raise e
  end
end