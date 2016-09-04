module FactualHelpers
  def find_by_factual_id factual_id
    Venue.where(factual_id: factual_id)
  end
end

RSpec.configure do |c|
  c.include FactualHelpers
end
