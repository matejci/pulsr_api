module Locationable
  extend ActiveSupport::Concern

  SEARCH_RADIUS = 2000 # meters
  EXTENDED_SEARCH_RADIUS = 5000 # meters
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)

  included do
    scope :close_to_old, -> (latitude, longitude, distance_in_meters = Locationable::SEARCH_RADIUS) do
      where(%{
        ST_DWithin(
          ST_SetSRID(ST_MakePoint(%s.longitude, %s.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(%f, %f), 4326)::geography,
          %d,
          false
        )
      } % [table_name, table_name, longitude, latitude, distance_in_meters])
    end
    scope :close_to, -> (longitude, latitude, distance_in_meters = Locationable::SEARCH_RADIUS) do
      where(%{
        ST_DWithin(
          lonlat,
          ST_SetSRID(ST_MakePoint(%f, %f), 4326)::geography,
          %d,
          false
        )
      } % [longitude, latitude, distance_in_meters])
    end
    scope :by_location, -> (latitude, longitude, radius = Locationable::SEARCH_RADIUS) do
      close_to(longitude, latitude, radius)
    end
    scope :within, -> boundaries do
      where(longitude: boundaries[:left]..boundaries[:right]).
      where(latitude: boundaries[:bottom]..boundaries[:top])
    end

    before_save :check_location
  end

  def check_location
    if latitude.present? && longitude.present? &&
      (latitude_changed? || longitude_changed?)

      self.lonlat = Locationable::GEO_FACTORY.point(longitude, latitude)
    end
  end

  module ClassMethods
    def fast_geo_search(latitude, longitude)
      ActiveRecord::Base.connection.execute("SET work_mem='40MB'")
      reference = close_to(latitude, longitude).load
      ActiveRecord::Base.connection.execute("RESET work_mem")
      reference
    end
  end
end
