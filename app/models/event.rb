class Event < ActiveRecord::Base
  include Locationable
  include Createable
  include Taggable
  include Actionable
  include Invitable
  include Flaggable

  attr_accessor :weight

  belongs_to :venue
  belongs_to :city
  belongs_to :user
  belongs_to :zone, class_name: City, foreign_key: 'zone_id'
  has_and_belongs_to_many :performers, -> { select("DISTINCT ON (performers.id) performers.*") }
  has_many :timetables do
    def upcoming(date = Time.current)
      first_after_date(date)
    end
  end
  has_many :instagram_places, through: :venue
  has_many :photo_objects, as: :object, dependent: :destroy
  has_many :photos, through: :photo_objects do
    def <<(photo)
      photo = photo.is_a?(Photo) ? photo : Photo.find(photo)
      photo_id = photo.id

      unless proxy_association.owner.photo_ids.include?(photo_id)
        super.<< photo
      end

      proxy_association.owner.photos
    end
  end
  has_many :posts, as: :item
  has_many :notifications, as: :object, dependent: :destroy


  acts_as_votable

  geocoded_by :full_address do |record, results|
    result = results.first

    record.lonlat = GEO_FACTORY.point(result.longitude, result.latitude)
  end

  validates :eventful_id, uniqueness: { message: "ID has already been taken", allow_blank: true, allow_nil: true }
  validates_inclusion_of :kind, in: %w{public private}

  scope :upcoming, -> { for_date(Date.today, 10.years) }
  scope :for_date, -> (date, upto = nil) { joins(:timetables).merge(Timetable.for_date(date, upto)) }
  scope :starting_today, -> { for_date(Time.current.beginning_of_day, 10.years) }
  scope :today, -> { for_date(Date.today) }
  scope :next_week, -> { for_date(Date.today, 7.days) }
  scope :without_photos, -> do
    joins("LEFT OUTER JOIN photo_objects ON photo_objects.object_id=events.id AND photo_objects.object_type = 'Event'").
    select("DISTINCT ON (events.id) events.*").
    where("photo_objects.id IS NULL")
  end
  scope :with_photos, -> do
    joins("LEFT OUTER JOIN photo_objects ON photo_objects.object_id=events.id AND photo_objects.object_type = 'Event'").
    select("DISTINCT ON (events.id) events.*").
    where("photo_objects.id IS NOT NULL")
  end
  scope :include_latest_timetable, -> { select('DISTINCT ON (events.id) events.*, timetables.starts_at as timetable_starts_at') }
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }
  scope :within_city, -> city { within city.boundary_corners }
  scope :missing_city, -> { where(city_id: nil) }
  scope :not_processed_photos, -> { where(photo_processed_at: nil) }
  scope :public_only, -> { where(kind: 'public') }
  scope :eventful_only, -> { where.not(eventful_id: nil) }
  scope :visible_to_user, -> (user) {
    event_ids = Invitation.events.active.where(user: user).pluck(:invitable_id)
    event_ids += user.event_ids

    where("kind = 'public' OR id IN (:event_ids)", {
      event_ids: event_ids
    })
  }
  scope :zoned, -> { where.not(zone_id: nil) }

  before_save :update_location!
  before_save :check_zone!

  update_index('search#venue') { venue }
  update_index('search#event', :self)

  def self.update_instagram_photos
    next_week.
      not_processed_photos.
      without_photos.
      with_coordinates.
      zoned.
      find_in_batches(batch_size: 2000) do |group|

      group.each do |event|
        Instagram::EventWorker.perform_later(event)
      end
    end
  end

  def self.get_for_pos(latitude, longitude, options)
    connection.execute("SET work_mem='40MB'")
    events = by_distance(latitude, longitude, options).
              includes(:venue).
              include_latest_timetable.
              public_only.
              load
    connection.execute("RESET work_mem")
    events
  end

  def self.by_distance latitude, longitude, options = {}
    options = options.reverse_merge({
      per_page: 10,
      page: 1
    })

    if options[:date].present?
      events = for_date(options[:date]).by_location(latitude, longitude)
    else
      events = today.by_location(latitude, longitude)
    end

    events.page(options[:page]).per(options[:per_page])
  end

  def self.create_from_eventful(data, city = nil)
    values = {}

    {
      description: "description",
      all_day: "all_day",
      eventful_url: "url",
      eventful_id: "id",
      starts_at: "start_time",
      ends_at: "stop_time",
      eventful_venue_id: "venue_id",
      name: "title"
    }.each do |to, from|
      values[to] = data[from] if data[from].present?
    end

    if data["venue_id"].present?
      venue = Venue.where(eventful_id: data["venue_id"]).first
      if venue.present?
        values["venue_id"] = venue.id
        values["latitude"] = venue.latitude
        values["longitude"] = venue.longitude
      end
    end

    values[:created_by] = Event::CREATED_BY_EVENTFUL

    values['images'] = extract_images(data)
    values['links'] = Eventful::Core.extract_links(data)

    values["city"] = city if city.present?

    event = create! values

    Timetable.process_event_timetable(event, data)

    Tagging.process_eventful_tags(data["tags"]["tag"], event) if data["tags"].present?
    event
  rescue ActiveRecord::RecordInvalid => e
    event = where(eventful_id: data['id']).first
  ensure
    event
  end

  def self.extract_images(data)
    Eventful::Core.extract_images(data)
  end

  def self.create_for_user(data, user)

    location = data.delete(:location)
    photo_ids = data.delete(:photo_ids)
    starts_at = data.delete(:starts_at)
    ends_at = data.delete(:ends_at)
    tags = data.has_key?(:tags) ? data.delete(:tags) : []

    event = new(data)
    event.created_by = Event::CREATED_BY_USER
    event.user = user
    event.starts_at = starts_at
    event.ends_at = ends_at

    if location.present?
      event.latitude = location[:latitude]
      event.longitude = location[:longitude]
      event.venue_id = location[:venue_id] if location[:venue_id].present?
    end

    if event.valid? && event.save

      # venue
      if !event.venue_id.present?
        event.update_attribute :venue, Venue.create_for_user(location, user)
      end

      # timetable
      if starts_at.present?
        Timetable.create_for_event(starts_at, ends_at, event)
        starts_at = DateTime.parse(starts_at).in_time_zone(Time.zone) if starts_at.is_a?(String)
        event.attend_for_user(user, starts_at)
      end

      # tags
      Tagging.create_tags_for_event(tags, event)

      # Add existing photos
      if photo_ids.present?
        photo_ids = photo_ids.map &:to_i
        photo_ids.each { |id| event.photos << id }
      end

    end

    event
  end

  def self.onboarding_events(user, invitee)
    events = user.saved_events

    if events.count < 4
      events += Event.next_week.order("RANDOM()").limit(4)
    end

    events.first(4)
  end

  def update_for_user data, user
    location = data.delete :location
    venue_id = data[:location].delete :venue_id if data[:location].present?
    photo_ids = data.delete :photo_ids
    starts_at = data.delete :starts_at
    ends_at = data.delete :ends_at

    tags = data.delete :tags
    clear_tags = data.delete :clear_tags
    tags = [] if !tags.present? && clear_tags

    if location.present?
      data[:latitude]  = location[:latitude] if location[:latitude].present?
      data[:longitude] = location[:longitude] if location[:longitude].present?

      venue_id = location.delete :venue_id

      if venue_id.present?
        data[:venue_id] = venue_id
      else
        data[:venue] = Venue.create_for_user(location, user)
      end
    end

    if update(data)
      # timetable
      if starts_at.present? && ends_at.present?
        self.timetables.first.update_time(starts_at, ends_at)
      end

      # tags
      if tags.is_a?(Array)
        Tagging.update_tags_for_event(tags, self)
      end

      reload

      return true
    end

    false
  end

  def update_from_eventful data, city = nil
    values = {}

    {
      description: "description",
      all_day: "all_day",
      starts_at: "start_time",
      ends_at: "stop_time",
      eventful_venue_id: "venue_id",
      name: "title"
    }.each do |to, from|
      if data[from].present? && data[from] != attributes[to]
        values[to] = data[from]
      end
    end

    if data["venue_id"].present? && data["venue_id"] != self.eventful_venue_id
      venue = Venue.where(eventful_id: data["venue_id"]).first
      if venue.present?
        values["venue_id"] = venue.id
        values["latitude"] = venue.latitude
        values["longitude"] = venue.longitude
      end
    end

    values["city"] = city if city.present?

    Timetable.process_event_timetable(self, data)

    update_attributes values unless values.empty?
  end

  def import_location_from_venue!
    if venue.present? && !latitude.present? && !latitude.present?
      update_attributes({
        latitude: venue.latitude,
        longitude: venue.longitude
      })
    end
  end

  def apply_vote(user, vote)
    self.vote_by :voter => user, :vote => vote
  end

  def full_address
    venue.full_address
  end

  def add_photo(photo)
    data = {
      object: self
    }

    if photo.is_a? Photo
      data[:photo] = photo
    else
      data[:photo_id] = photo
    end

    PhotoObject.where(data).first_or_create
  end

  def update_instagram_photos
    Instagram::PhotoImporter.import_for_event(self)
  end

  def random_photo_url
    photos.not_flagged.sample.try(:public_url)
  end

  def random_crop_photo_url
    photos.not_flagged.can_center_crop.sample.try(:public_url)
  end

  def photos_url
    photos.not_flagged.map(&:public_url)
  end

  def pos_photos
    photos.not_flagged.can_center_crop.map(&:pos_json)
  end

  def pos_photo
    photos.not_flagged.can_center_crop.sample.try(:pos_json)
  end

  def pos_type
    self.class.to_s.downcase
  end

  def update_location!
    if venue.present? && venue_id_changed?
      self.latitude = venue.latitude if venue.latitude.present?
      self.longitude = venue.longitude if venue.longitude.present?
    end
  end

  def check_zone!
    if zone_id.present?
      taggings.where(zone_id: nil).update_all(zone_id: zone_id)
    end
  end

  def get_pos(user = nil, options = {})
    starting_date = try(:timetable_starts_at) || starts_at || options[:starts_at]

    data = {
      name: name,
      latitude: latitude,
      longitude: longitude,
      type: pos_type,
      photo: photo_collection.first,
      starts_at: starting_date,
      saved: options[:saved],
      data: {
        event_id: id,
        kind: kind,
        user_id: user_id
        # images: photos_url,
        # description: description
      },
      weight: weight
    }

    if venue.present?
      data[:street_address] = venue.street_address
      data[:city] = venue.city
      data[:region] = venue.region
      data[:zip_code] = venue.zip_code
      data[:country] = venue.country
      data[:venue_name] = venue.name
    end

    data
  end

  def to_pos(user = nil, options = {}, full_text_search = false)
    data = get_pos(user, options)
    data.delete :type
    data.delete :saved
    data.merge!({
      zone_id: self.zone_id,
      object: self,
      taste_data: [0]*(Taste::TASTE_COUNT + 1),
      public: public?
    })


    if self.photos.present?
      p = self.photos.first
      photo = { :id => p.id, :url => p.url.nil? ? p.file.url : p.url, :kind => p.kind, :caption => p.caption }
      data[:photo] = photo
    end

    full_text_search ? PointOfInterest.new(data) : PointOfInterest.create(data)
  end

  def user_can_invite?(inviting_user)
    if public?
      true
    else
      user == inviting_user || friend_can_invite?(inviting_user)
    end
  end

  def friend_can_invite?(inviting_user)
    friends_can_invite? && inviting_user.friends_with?(user)
  end

  def created_by
    user.try(:display_name)
  end

  def public?
    kind == "public"
  end

  def private?
    kind == "private"
  end

  def as_json(*)
    EventPresenter.prepare_with_date(self)
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
    Taste.joins(tags: :taggings)
         .select("DISTINCT ON (tastes.id) tastes.#{column}")
         .where(taggings: {taggable_id: self.id, taggable_type: 'Event'})
  end

  def formatted_start_date_for_invite_mailer
    if (timetable = timetables.upcoming.first).present?
      timetable.starts_at.strftime('%a, %m/%d ')
    else
      ""
    end
  end

end

# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  eventful_id             :string
#  eventful_url            :string
#  name                    :string
#  description             :text
#  time_zone               :string
#  starts_at               :datetime
#  ends_at                 :datetime
#  all_day                 :boolean
#  free                    :boolean
#  eventful_venue_id       :string
#  links                   :json
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  venue_id                :integer
#  data                    :json
#  images                  :string           default([]), is an Array
#  title                   :text
#  twitter_username        :string
#  hashtag                 :string
#  url                     :string
#  latitude                :decimal(10, 6)
#  longitude               :decimal(10, 6)
#  created_by              :string
#  latest_timetable_at     :datetime
#  location                :point            point, 0
#  lonlat                  :geography({:srid point, 4326
#  user_id                 :integer
#  kind                    :enum             default("public")
#  friends_can_invite      :boolean
#  photo_processed_at      :datetime
#  cached_votes_total      :integer          default(0)
#  cached_votes_score      :integer          default(0)
#  cached_votes_up         :integer          default(0)
#  cached_votes_down       :integer          default(0)
#  cached_weighted_score   :integer          default(0)
#  cached_weighted_total   :integer          default(0)
#  cached_weighted_average :float            default(0.0)
#  timezone_parse_at       :datetime
#  zone_id                 :integer
#  zoned_at                :datetime
#
