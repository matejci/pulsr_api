class CityEventsWorker < ActiveJob::Base
  queue_as :default

  def perform(city, options = {})
    Eventful::City.process(city, options) do |event, options|
      EventWorker.perform_later(event, city)
    end
  rescue Exception => e
    data = {
      name: 'CityEventsWorker',
      data: {
        values: city
      },
      error: e.message
    }
    Failure.create data

    raise e
  end
end