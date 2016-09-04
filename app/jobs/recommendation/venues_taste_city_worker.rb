class Recommendation::VenuesTasteCityWorker < ActiveJob::Base
  queue_as :recommendations

  def perform(taste, city, date)
    Time.use_zone(city.timezone) do
      PointOfInterest.transaction do
        Recommendation::Parser.get_venues(taste, city, date).find_each do |venue|
          Recommendation::Parser.process_venue(venue, taste, city, date)
        end
      end
    end
  end

end