class Factual::DropboxWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(delta = nil)
    Factual::Dropbox.webhook_update(delta)
  rescue Exception => e
    data = {
      name: 'Factual::DropboxWorker',
      data: {
        delta: delta
      },
      error: e.message
    }

    Failure.create data

    raise e
  end
end