class Eventful::City
  class << self
    def process city, options = {}, &block
      new(city, options).perform(&block)
    end
  end

  def initialize city, options = {}
    @city = city
    @options = options
  end

  def perform(&block)
    EventfulClient.search_by_location(@city.name, @options, &block)
  end
end