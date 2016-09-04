class Contact::RegistrationWorker < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.contact_book.registration_find_connections
  rescue Exception => e
    data = {
      name: 'Contact::RegistrationWorker',
      data: {
        user: user.id
      },
      error: e.message
    }
    Failure.create data

    raise e
  end

end
