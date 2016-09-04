class Twitter::VenueWorker < ActiveJob::Base
  queue_as RateLimiter::SEARCH_TWITTER_QUEUE

  def perform(venue)
    venue.update_twitter_username
  rescue Exception => e
    data = {
      name: 'Twitter::VenueWorker',
      data: {
        venue: venue
      },
      error: e.message
    }

    Failure.create data

    raise e
  end
end