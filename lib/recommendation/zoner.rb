class Recommendation::Zoner
  def self.zone_venues
    City.with_boundaries.each do |city|
      Venue.where(zoned_at: nil).within(city.get_edges).find_each do |venue|
        venue.update(zone: city, zoned_at: Time.current)
        venue.category_venues.update_all(zone_id: city)
        venue.taggings.update_all(zone_id: city)
      end
    end
  end

  def self.zone_events
    City.with_boundaries.each do |city|
      Event.where(zoned_at: nil).within(city.get_edges).find_each do |event|
        event.update(zone: city, zoned_at: Time.current)
        event.taggings.update_all(zone_id: city)
      end
    end
  end
end