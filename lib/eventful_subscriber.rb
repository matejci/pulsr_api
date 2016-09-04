class EventfulSubscriber
  PERIOD = 5.days

  class << self
    def process_future_events(options = {})
      City.with_boundaries.each do |city|
        CityEventsWorker.perform_later(city, options)
      end
    end
  end
end