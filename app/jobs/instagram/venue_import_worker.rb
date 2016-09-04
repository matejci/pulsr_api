class Instagram::VenueImportWorker < ActiveJob::Base
  queue_as RateLimiter::INSTAGRAM_QUEUE

  def perform venue
    venue.import_instagram_photos
  rescue Exception => e
    data = {
      name: 'Instagram::VenueImportWorker',
      data: {
        venue: venue
      },
      error: e.message
    }
    Failure.create data

    raise e
  end
end