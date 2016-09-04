class Recommendation::TasteWorker < ActiveJob::Base
  queue_as :recommendations

  def perform(city)
    Recommendation::Parser.process_in_worker = false
    Recommendation::Parser.process_cities
  end
end