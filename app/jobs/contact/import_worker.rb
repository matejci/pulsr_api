class Contact::ImportWorker < ActiveJob::Base
  queue_as :default

  def perform(user, device_id)
    user.contact_book.import_contacts_from(device_id)
  rescue Exception => e
    data = {
      name: 'Contact::ImportWorker',
      data: {
        user: user.id,
        device_id: device_id
      },
      error: e.message
    }
    Failure.create data

    raise e
  end

end
