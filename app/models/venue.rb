class Venue < ActiveRecord::Base
  include Locationable
  include Createable
  include Taggable
  include Actionable
  include Invitable
  include Flaggable

  HIGH_PRECISION_RADIUS = 8

  belongs_to :user
  belongs_to :city_object, class_name: City, foreign_key: 'city_id'
  belongs_to :zone, class_name: City, foreign_key: 'zone_id'
  has_many :events
  has_and_belongs_to_many :categories, dependent: :destroy
  has_many :category_venues
  has_many :instagram_places
  has_many :photos do
    def <<(photo)
      photo = photo.is_a?(Photo) ? photo : Photo.find(photo)
      photo_id = photo.id

      unless proxy_association.owner.photo_ids.include?(photo_id)
        super.<< photo
      end

      proxy_association.owner.photos
    end
  end
  has_many :posts, as: :item, dependent: :destroy
  has_many :notifications, as: :object, dependent: :destroy

  acts_as_votable

  validates :eventful_id, uniqueness: { message: "ID has already been taken", allow_blank: true, allow_nil: true }
  validates :factual_id, uniqueness: { message: "ID has already been taken", allow_blank: true, allow_nil: true }

  scope :eventful, -> { where.not(eventful_id: nil) }
  scope :factual, -> { where.not(factual_id: nil) }
  scope :unprocessed, -> { eventful.where(processed_at: nil).not_placeholder_venue }
  scope :processed, -> { eventful.where.not(processed_at: nil).not_placeholder_venue }
  scope :has_twitter, -> { where.not(twitter: nil) }
  scope :not_placeholder_venue, -> do
    where('description NOT LIKE ? OR description IS NULL', '%This venue is for events taking place in%')
  end
  scope :has_city_in_name, -> do
    where("name ~* ? OR city ~* ?", "(#{City::ABBREVIATIONS.keys.join('|')})", "(#{City::ABBREVIATIONS.keys.join('|')})")
  end
  scope :has_not_city_in_name, -> do
    where("name !~* ? OR city ~* ?", "(#{City::ABBREVIATIONS.keys.join('|')})", "(#{City::ABBREVIATIONS.keys.join('|')})")
  end
  scope :pending_deletion, -> { where.not(pending_at: nil).where(pending_at: 10.years.ago..60.days.ago) }
  scope :without_instagram_import, -> { eventful.with_instagram_places.where(instagram_at: nil) }
  scope :with_instagram_places, -> {
    select("DISTINCT ON (venues.id) venues.*").joins(:instagram_places).where('instagram_places.id IS NOT NULL')
  }
  scope :open_on_day, -> date do
    day = Timetable::week_day(date)
    where('hours ? :day', {day: day})
  end
  scope :zoned, -> { where.not(zone_id: nil) }

  before_save :check_zone!

  update_index('search#venue', :self)
  update_index('search#event') { events }

  geocoded_by :full_address do |record, results|
    result = results.first
    record.lonlat = GEO_FACTORY.point(result.longitude, result.latitude)
  end

  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.street_address = geo.street_address
      obj.city = geo.city
      obj.region = geo.state
      obj.zip_code = geo.postal_code
      obj.country = geo.country
      obj.name = geo.neighborhood
    end
  end

  class << self
    def by_distance latitude, longitude, options = {}
      options = options.reverse_merge({
        per_page: 10,
        page: 1
      })

      events = by_location(latitude, longitude)

      events.page(options[:page]).per(options[:per_page])
    end

    def get_for_pos(latitude, longitude, options)
      connection.execute("SET work_mem='40MB'")
      venues = by_distance(latitude, longitude, options)
      if options[:date].present?
        venues = venues.open_on_day(options[:date])
      end
      venues.load
      connection.execute("RESET work_mem")
      venues
    end

    def update_twitter_username offset = 0
      # Venues without city name in the title need to do single API call
      options = { batch_size: TwitterClient::SEARCH_BATCH_SIZE }
      unprocessed.has_not_city_in_name.find_in_batches(options) do |group|
        group.each do |venue|
          delay = (offset * 15).minutes

          Twitter::VenueWorker
            .set(wait: delay)
            .perform_later(venue)
        end

        offset += 1
      end

      # Venues with city name in the title need to do two API calls
      options[:batch_size] = TwitterClient::SEARCH_HALF_BATCH_SIZE
      unprocessed.has_city_in_name.find_in_batches(options) do |group|
        group.each do |venue|
          delay = (offset * 15).minutes

          Twitter::VenueWorker
            .set(wait: delay)
            .perform_later(venue)
        end

        offset += 1
      end

      offset
    end

    def find_factual_candidate_from_venue(venue)
      if venue.latitude.present? && venue.longitude.present? && venue.name.present?
        result = find_factual_candidate(venue.latitude, venue.longitude, venue.name, {street_address: venue.street_address})

        unless result.present?
          if venue.name.present?
            query = {
              city: venue.city
            }
            query[:zip_code] = venue.zip_code if venue.zip_code.present?

            venues = Venue.factual.where(query).where('lower(name) = ?', venue.name.downcase)

            if venues.count == 1
              result = venues.first
            end
          end
        end

        result
      end
    end

    def find_factual_candidate latitude, longitude, name, data = {}
      return if latitude.nil?

      venues = Venue.factual.by_location(latitude, longitude, 2000).where(name: name)

      if venues.count == 1
        venues.first
      elsif venues.count > 1 && data[:street_address].present?
        phrase = data[:street_address].split(/[^\w]+/).max_by(&:length)
        candidates = []
        venues.each do |current_venue|
          if /#{phrase}/i === current_venue.street_address
            candidates << current_venue
          end
        end

        candidates.max_by {|v| v.factual_existence.present? ? v.factual_existence : 0.0 }
      end
    end

    def create_for_user(data, user)
      if data.present? && data[:latitude].present? && data[:longitude].present?
        venue = new(data)
        candidate_venue = find_factual_candidate_from_venue(venue)

        if candidate_venue.present?
          return candidate_venue
        else
          existing_venue = Venue.close_to(data[:longitude], data[:latitude], HIGH_PRECISION_RADIUS)

          if existing_venue.any?
            return existing_venue.first
          else
            venue.reverse_geocode
            venue.created_by = Venue::CREATED_BY_USER
            venue.save
            return venue
          end
        end
      end
    end

    def create_from_eventful(data, event = nil)
      values = {}

      {
        eventful_id: 'id',
        eventful_url: 'url',
        name: 'name',
        description: 'description',
        street_address: 'address',
        city: 'city',
        region: 'region',
        zip_code: 'postal_code',
        country: 'country',
        time_zone: 'time_zone',
        latitude: 'latitude',
        longitude: 'longitude'
      }.each do |to, from|
        values[to] = data[from] if data[from].present?
      end

      values[:created_by] = Venue::CREATED_BY_EVENTFUL

      values['images'] = Eventful::Core.extract_images(data)
      values['links'] = Eventful::Core.extract_links(data)

      venue = new values

      factual_venue = find_factual_candidate_from_venue(venue)
      if factual_venue.present?
        venue = factual_venue.merge_venue!(venue)
      else
        venue.save!
      end

      Tagging.process_eventful_tags(data["tags"]["tag"], venue) if data["tags"].present?
      venue
    rescue ActiveRecord::RecordInvalid => e
      venue = where(eventful_id: data['id']).first
    ensure
      if event.present? && event.is_a?(Event)
        update_data = {
          venue: venue
        }

        if venue.latitude.present?
          update_data[:latitude] = venue.latitude
          update_data[:longitude] = venue.longitude
        end

        event.update_attributes update_data
      end
      venue
    end

    def start_import_instagram_photos offset = 0
      options = { batch_size: Instagram::PhotoImporter::BATCH_SIZE }
      without_instagram_import.
        zoned.
        find_in_batches(options) do |group|
        group.each do |venue|
          delay = (offset * 60).minutes

          Instagram::VenueImportWorker
            .set(wait: delay)
            .perform_later(venue)
        end

        offset += 1
      end

      offset
    end

  end

  def import_instagram_photos
    Instagram::PhotoImporter.import_for_venue self
  end

  def update_from_eventful(data)
    values = {}

    {
      name: 'name',
      description: 'description',
      street_address: 'address',
      city: 'city',
      region: 'region',
      zip_code: 'postal_code',
      country: 'country',
      time_zone: 'time_zone',
      latitude: 'latitude',
      longitude: 'longitude'
    }.each do |to, from|
      if data[from].present? && data[from] != self.attributes[to]
        values[to] = data[from]
      end
    end

    self.update_attributes values
  end

  def update_twitter_username
    Twitter::Venue.new(self).process
  end

  def twitter_data
    data['twitter'] || data[:twitter]
  end

  def scores
    data['twitter_scores'] || data[:twitter_scores]
  end

  def location
    "#{city} #{region} #{country}".squeeze
  end

  def merge_venue! venue
    [:eventful_id, :eventful_url, :name, :description,
    :street_address, :city, :region, :zip_code,
    :country, :time_zone, :latitude, :longitude,
    :images, :telephone_number, :links, :email,
    :cuisine, :hours, :factual_id, :short_factual_id,
    :created_by, :factual_rating, :factual_price, :processed_at,
    :twitter, :url, :factual_existence, :pending_at].each do |key|
      self[key] = venue[key] unless self[key].present?
    end

    venue.data.keys.each do |key|
      self.data[key] = venue.data[key] unless self.data[key].present?
    end

    if venue.persisted?
      venue.events.update_all(venue_id: self.id)
      venue.instagram_places.update_all(venue_id: self.id)
      venue.photos.update_all(venue_id: self.id)
      venue.taggings.update_all(taggable_id: self.id)
      self.tags << (venue.tags - self.tags)
      venue.delete
    end

    self.updated_at = Time.current
    self.save!
    self
  end

  def shortened_name
    short_name = name.clone
    name.scan City::ABBREVIATIONS_REGEX do |city_name|
      city_name = city_name.first
      short_name.gsub! city_name, City.abbreviation_for(city_name)
    end
    short_name
  end

  def name_without_city
    name.clone.gsub(City::ABBREVIATIONS_SPACE_REGEX, ' ')
  end

  def city_in_name?
    City::ABBREVIATIONS_SPACE_REGEX === name ||
    City::ABBREVIATIONS_SPACE_REGEX === city
  end

  def abbreviated_city
    City.abbreviation_for(city)
  end

  def official_links
    candidates = links.select do |link|
      if /ticket/i === link['type'] ||
         /(?:ticket|venue|promoter|listing|event)/i === link['url'] ||
         /(?:sfstation|eventseye|nyc-arts)/i === link['url'] ||
         /(?:neimanmarcus|yelp|google)/i === link['url']
        false
      else
        true
      end
    end

    response = []
    ['Website', 'Official Site', 'All'].each do |type|
      response += candidates.select do |link|
        if type == "All"
          link['type'] != type
        else
          link['type'] == type
        end
      end
    end
    response.map {|link| link['url']}
  end

  def eventful?
    eventful_id.present?
  end

  def factual?
    factual_id.present?
  end

  def pricing
    factual_price
  end

  def apply_vote(user, vote)
    self.vote_by :voter => user, :vote => vote
  end

  def merge_to_factual_venue!
    if eventful? && !factual?
      factual_venue = Venue.find_factual_candidate_from_venue(self)
      if factual_venue.present?
        return factual_venue.merge_venue!(self)
      end
    end
  end

  def full_address
    [street_address, city, region, country].compact.join(', ')
  end

  def pos_type
    self.class.to_s.downcase
  end

  def random_photo_url
    photos.not_flagged.sample.try(:public_url)
  end

  def random_crop_photo_url
    photos.not_flagged.can_center_crop.sample.try(:public_url)
  end

  def pos_photos
    photos.not_flagged.can_center_crop.map &:pos_json
  end

  def pos_photo
    photos.not_flagged.can_center_crop.sample.try(:pos_json)
  end

  def photos_url
    photos.not_flagged.map(&:public_url)
  end

  def today_hours
    date_hours(Date.today)
  end

  def date_hours(date)
    if hours.is_a? Hash
      opening_hours = hours[date.strftime("%A").downcase]
      if opening_hours.present?
        if opening_hours.count == 1
          opening_hours.first
        else
          opening_hours
        end
      end
    end
  end

  def get_pos(user = nil, options = {})
    starting_date = options[:starts_at] || try(:starts_at) || Time.current.beginning_of_day

    data = {
      name: name,
      latitude: latitude,
      longitude: longitude,
      type: pos_type,
      street_address: street_address,
      city: city,
      region: region,
      zip_code: zip_code,
      country: country,
      photo: photo_collection.first,
      saved: options[:saved],
      opening_hours: date_hours(starting_date),
      starts_at: starting_date,
      data: {
        venue_id: id,
        pricing: pricing
        # images: photos_url,
        # description: description
      }
    }
  end

  def to_pos(user = nil, options = {}, full_text_search = false)
    data = get_pos(user, options)
    data.delete :type
    data.delete :saved
    data.merge!({
      zone_id: self.zone_id,
      object: self,
      taste_data: [0]*(Taste::TASTE_COUNT + 1),
      public: true
    })

    full_text_search ? PointOfInterest.new(data) : PointOfInterest.create(data)
  end

  def created_by
    user.try(:display_name)
  end

  def photo_collection
    photos.present? ? pos_photos : taste_photo.map(&:pos_json)
  end

  def taste_photo
    [].tap do |photos_collection|
      photos = Photo.joins(:tastes).where(tastes: {id: self.tastes('id')})
      photos_collection << photos.random.first if photos.present?
    end
  end

  def tastes(column = "*")
    taste_collection = Taste.joins(categories: :venues)
                  .select("DISTINCT ON (tastes.id) tastes.#{column}")
                  .where(venues: {id: self.id})

    unless taste_collection.present?
      taste_collection = Taste.joins(tags: :taggings)
           .select("DISTINCT ON (tastes.id) tastes.#{column}")
           .where(taggings: {taggable_id: self.id, taggable_type: 'Venue'})
    end

    taste_collection
  end

  def check_zone!
    if zone_id.present?
      taggings.where(zone_id: nil).update_all(zone_id: zone_id)
    end
  end

end

# == Schema Information
#
# Table name: venues
#
#  id                      :integer          not null, primary key
#  eventful_id             :string
#  eventful_url            :string
#  name                    :string
#  description             :text
#  category                :string
#  street_address          :string
#  city                    :string
#  region                  :string
#  zip_code                :string
#  country                 :string
#  time_zone               :string
#  latitude                :decimal(10, 6)
#  longitude               :decimal(10, 6)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  images                  :string           default([]), is an Array
#  telephone_number        :string
#  links                   :json
#  email                   :string
#  cuisine                 :json
#  hours                   :jsonb
#  factual_id              :string
#  short_factual_id        :string
#  created_by              :string
#  factual_rating          :decimal(, )
#  factual_price           :decimal(, )
#  processed_at            :datetime
#  twitter                 :string
#  data                    :json             default({})
#  url                     :string
#  factual_existence       :decimal(, )
#  pending_at              :datetime
#  instagram_at            :datetime
#  location                :point            point, 0
#  lonlat                  :geography({:srid point, 4326
#  user_id                 :integer
#  city_id                 :integer
#  cached_votes_total      :integer          default(0)
#  cached_votes_score      :integer          default(0)
#  cached_votes_up         :integer          default(0)
#  cached_votes_down       :integer          default(0)
#  cached_weighted_score   :integer          default(0)
#  cached_weighted_total   :integer          default(0)
#  cached_weighted_average :float            default(0.0)
#  zone_id                 :integer
#  zoned_at                :datetime
#
