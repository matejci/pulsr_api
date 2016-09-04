class Contact::CacheWorker < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.update_contact_cache
  rescue Exception => e
    data = {
      name: 'Contact::CacheWorker',
      data: {
        user: user.id
      },
      error: e.message
    }
    Failure.create data

    raise e
  end

end
