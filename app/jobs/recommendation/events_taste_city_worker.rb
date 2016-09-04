class Recommendation::EventsTasteCityWorker < ActiveJob::Base
  queue_as :recommendations

  def perform(taste, city, date)
    Time.use_zone(city.timezone) do
      PointOfInterest.transaction do
        Recommendation::Parser.get_events(taste, city, date).find_each do |event|
          Recommendation::Parser.process_event(event, taste, city, date)
        end
      end
    end
  end
end