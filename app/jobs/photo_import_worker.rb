class PhotoImportWorker < ActiveJob::Base
  queue_as :photo_import

  def perform(photo)
    photo.import!
  rescue Exception => e
    data = {
      name: 'PhotoImportWorker',
      data: {
        photo: photo
      },
      error: e.message
    }
    Failure.create data

    raise e
  end
end