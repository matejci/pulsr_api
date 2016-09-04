class Post < ActiveRecord::Base
  attr_accessor :location_name
  attr_accessor :address

  include Locationable
  include Flaggable

  HIGH_PRECISION_RADIUS = 8

  belongs_to :user
  belongs_to :photo
  belongs_to :item, polymorphic: true
  belongs_to :source, polymorphic: true
  belongs_to :post_type
  belongs_to :place

  acts_as_votable

  validates_length_of :body, maximum: 200, allow_blank: true, allow_nil: true
  validates_uniqueness_of :photo_id, scope: [:item_type, :item_id], allow_nil: true, allow_blank: true

  PostType::KIND.keys.each do |service|
    scope "#{service}_post", -> { where(post_type_id: PostType::KIND[service]) }
  end

  before_validation :update_location, :check_nearby_places
  before_validation :check_privacy

  scope :public_only, -> { where(is_private: false) }
  scope :recent, -> { where(created_at: 10.days.ago..10.days.since) }

  scope :get_by_location, -> (latitude, longitude, radius = Locationable::SEARCH_RADIUS) {
    by_location(latitude, longitude, radius).public_only.recent
  }

  scope :filter_out_reported, -> (reported_posts) { where.not("id in (?)", reported_posts) }
  scope :filter_out_blocked_users, -> (blocked_users) { where("user_id not in (?) or user_id is null", blocked_users) }

  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      place = obj.build_place
      place.street_address = geo.street_address
      place.postal_code = geo.postal_code
      place.address_locality = geo.city
      place.address_region = geo.state_code
      place.location_name = geo.neighborhood
      place.longitude = geo.longitude
      place.latitude = geo.latitude
      #place.lonlat = GEO_FACTORY.point(geo.longitude, geo.latitude)
      place
    end
  end

  class << self
    def create_from_photo photo, options = {}
      data = {
        photo: photo,
        body: photo.caption,
        source: photo,
        user: photo.user,
        post_type_id: photo.get_post_type
      }

      if options[:item].present?
        data[:item] = options[:item]
      else
        data[:item] = photo.venue
      end

      create(data)
    end

    def create_from_tweet tweet

      urls = URI.extract(tweet[:text], ['https', 'http'])

      if urls.any?
        image_url = CrawlerService.fetch_meta_property(urls.first)
      end

      data = {
        body: tweet.text,
        post_type_id: PostType::KIND[:twitter],
        source: tweet,
        latitude: tweet.latitude,
        longitude: tweet.longitude
      }

      data[:instagram_image_url] = image_url if !image_url.nil?

      if (photos = tweet.photos).present?
        data[:photo_id] = photos.first.id
      end

      create(data)
    end

    def create_user_post data, user
      # Filter out all fields that do not belong in the post model.
      allowed_fields = %i{photo_id photo_file body latitude longitude remarks}
      data.permit(*allowed_fields)

      # Add the post type id, and authoring user.
      data.merge!({
        post_type_id: PostType::KIND[:user],
        user: user
        })

      # If a photo was included, create it and add a reference.
      if data[:photo_file].present?
        data[:photo] = Photo.create_for_user({
          file: data[:photo_file]
          }, user)
        data.delete :photo_file
      end

      create(data)
    end
  end


  def update_with_photo data
    data.delete(:item) if data[:item] == item

    if data[:photo_file].present?
      data[:photo] = Photo.create_for_user({
        file: data.delete(:photo_file)
        }, user)
    end

    update(data)
  end

  def display_name
    if user.present?
      user.display_name
    elsif source.present?
      source.user_display_name
    end
  end

  def avatar_url
    if user.present? && user.avatar.present?
      user.avatar.url
    elsif source.present?
      source.user_avatar_url
    end
  end

  def as_json(*)
    data = {
      id: id,
      body: body,
      created_at: created_at,
      updated_at: updated_at,
      user_id: user_id,
      display_name: display_name,
      avatar_url: avatar_url,
      item_id: item_id,
      item_type: item_type,
      post_type_id: post_type_id,
      latitude: latitude,
      longitude: longitude,
      like_count: cached_votes_up,
      dislike_count: cached_votes_down,
      like_score: cached_weighted_score,
      remarks: remarks,
      instagram_image_url: instagram_image_url
    }

    if place.present?
      place_data = {
        address: {
          address_locality: place.address_locality,
          address_region: place.address_region,
          postal_code: place.postal_code,
          street_address: place.street_address
        },
          location_name: place.location_name,
          venue_name: place.venue_name,
          venue_id: place.venue_id
      }

      data = data.merge(place_data)
    end

    if photo_id.present?
      data[:photo_id] = photo_id
      data[:photo_url] = photo.try(:public_url)
    end

    data
  end

  def as_json_for_user(user)
    as_json.tap do |data|
      if user.present?
        data[:liked] = voted_by?(user)
      end
    end
  end

  def is_liked_by?(user)
    user.liked?(self)
  end

  def is_disliked_by?(user)
    user.disliked?(self)
  end

  def voted_by? user
    case user.voted_as_when_voted_for(self)
    when true
      "like"
    when false
      "dislike"
    else
      "pending"
    end
  end

    private

  def check_nearby_places
    # If there is an address, prefer the lat/lon of the address over the user's location.
    if address.present? then
      address_location = Geocoder.search(address)
      if address_location.first.present? then
        self.latitude = address_location.first.data["geometry"]["location"]["lat"]
        self.longitude = address_location.first.data["geometry"]["location"]["lng"]
      end
    end

    # Look for venues near the specified latitude and longitude.
    nearby_venues = check_nearby_venues

    if nearby_venues.first.nil?
      near_results = Place.close_to(self.longitude, self.latitude, HIGH_PRECISION_RADIUS)

      if self.location_name.present? then
        near_results = near_results.where("location_name ILIKE ?", "%#{self.location_name}%")
      end

      if near_results.first.nil?
        new_place = reverse_geocode
      else
        near_place = near_results.first
        self.place_id = near_place.id
      end
    else
      place = self.build_place
      place.venue_name = nearby_venues.first.name
      place.venue_id = nearby_venues.first.id
      place.street_address = nearby_venues.first.street_address
      place.postal_code = nearby_venues.first.zip_code
      place.address_locality = nearby_venues.first.city
      place.address_region = nearby_venues.first.region
      place.longitude = nearby_venues.first.longitude
      place.latitude = nearby_venues.first.latitude
    end
  end

  def check_nearby_venues
    nearby_venues = Venue.close_to(self.longitude, self.latitude, HIGH_PRECISION_RADIUS)

    if self.location_name.present? then
      nearby_venues = nearby_venues.where("name ILIKE ?", "%#{self.location_name}%")
    end

    return nearby_venues
  end

  def update_location
    self.latitude = latitude || item.try(:latitude) || photo.try(:latitude) || source.try(:latitude)
    self.longitude = longitude || item.try(:longitude) || photo.try(:longitude) || source.try(:longitude)
  end

  def check_privacy
    if item.present? && item.is_a?(Event) && item.kind == "private"
     self.is_private = true
    end
  end
end

# == Schema Information
#
# Table name: posts
#
#  id                      :integer          not null, primary key
#  body                    :text
#  user_id                 :integer
#  photo_id                :integer
#  item_id                 :integer
#  item_type               :string
#  post_type_id            :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  latitude                :decimal(, )
#  longitude               :decimal(, )
#  lonlat                  :geography({:srid point, 4326
#  source_id               :integer
#  source_type             :string
#  is_private              :boolean          default(FALSE)
#  cached_votes_total      :integer          default(0)
#  cached_votes_score      :integer          default(0)
#  cached_votes_up         :integer          default(0)
#  cached_votes_down       :integer          default(0)
#  cached_weighted_score   :integer          default(0)
#  cached_weighted_total   :integer          default(0)
#  cached_weighted_average :float            default(0.0)
#  remarks                 :text
#  place_id                :integer
#
