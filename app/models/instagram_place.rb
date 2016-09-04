class InstagramPlace < ActiveRecord::Base
  belongs_to :venue

  validates_uniqueness_of :place_id

  def self.get_for_venue(venue)
    regex = /#{venue.name}/i
    places = []

    Instagram::PhotoImporter.find_places_for_venue(venue).each do |place|
      if regex =~ place["name"]
        places << where(place_id: place["id"]).first_or_create(venue_id: venue.id)
      end
    end

    places
  end

  def self.create_for(instagram_place_id, venue_id = nil)
    where(place_id: instagram_place_id).first_or_create(venue_id: venue_id)
  end
end

# == Schema Information
#
# Table name: instagram_places
#
#  id         :integer          not null, primary key
#  venue_id   :integer
#  name       :string
#  factual_id :string
#  place_id   :integer
#
