class Photo < ActiveRecord::Base
  include Locationable
  include Flaggable

  belongs_to :venue
  belongs_to :instagram_place
  belongs_to :user
  belongs_to :tweet
  has_many :photo_objects, dependent: :destroy
  has_many :tastes, through: :photo_objects, source: :object, source_type: 'Taste'
  has_many :events, through: :photo_objects, source: :object, source_type: 'Event'
  has_many :performers, through: :photo_objects, source: :object, source_type: 'Performer'
  has_many :posts

  #WARNING KIND_TYPES is used for enumeration so the order must be preserved
  KIND_TYPES = [:standard, :instagram, :flickr, :facebook, :eventful, :twitter, :stock].freeze
  enum kind: KIND_TYPES

  KIND_TYPES.each do |kind_type|
    scope "is_#{kind_type}", -> { where(kind: kinds[kind_type]) }
  end

  has_attached_file :file, styles: {
    thumb: '100x100>',
    medium: '300x300>'
  }
  validates_attachment :file, content_type: {
    content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  }

  IMPORT_TYPE = {
    place_id: 'place_id',  # Imported for specific place id
    instagram_user: 'instagram_user', # Imported to specific instagram user
    performer: 'performer', # Imported for specific performer
    geolocation: 'geolocation' # Imported from location coordinates
  }

  after_commit :check_photo_import
  after_create :create_post

  scope :can_center_crop, -> do
    where("(meta_data->'center_crop' = 'true'::jsonb) OR (kind = 0 AND meta_data = '{}'::jsonb)")
  end
  scope :uploaded, -> { where.not(file_file_name: nil) }
  scope :not_uploaded, -> { where(file_file_name: nil) }
  scope :flagged, -> { includes(:flags).where.not(flags: {flaggable_id: nil}) }
  scope :not_flagged, -> { includes(:flags).where(flags: {flaggable_id: nil}) }

  class << self
    def create_for_user(data, user)
      data.merge!({
        kind: :standard,
        user: user
      })

      create(data)
    end

    def create_for_tweet(tweet, options = {})
      if tweet.photo_entities.present?
        tweet.photo_entities.each do |url|
          content = {
            kind: :twitter,
            tweet: tweet,
            url: url
          }

          create(content)
        end
      end
    end

    def create_instagram(data, options = {})
      content = {
        kind: :instagram,
        instagram_id: data['id']
      }
      if options[:meta_content].present?
        data[:meta_content] = options[:meta_content]
      end

      content = prepare_for_instagram(content, data)

      photo = create content

      photo
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation => e
      return find_by(instagram_id: data['id'])
    end

    def create_instagram_for_user data, username, options = {}
      content = {
        kind: :instagram,
        instagram_id: data['id']
      }
      if options[:meta_content].present?
        data[:meta_content] = options[:meta_content]
      end

      content = prepare_for_instagram(content, data)
      content[:data][:instagram][:username] = username

      photo = create content

      photo
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation => e
      return find_by(instagram_id: data['id'])
    end

    def create_instagram_for_place data, instagram_place, options = {}
      venue_id = options[:venue_id] if options.has_key?(:venue_id)
      if instagram_place.is_a? InstagramPlace
        instagram_place_id = instagram_place.id
        venue_id = instagram_place.venue_id
      else
        InstagramPlace.create_for(instagram_place, venue_id)
        instagram_place_id = instagram_place
      end

      content = {
        instagram_place_id: instagram_place_id,
        venue_id: venue_id,
        kind: :instagram,
        instagram_id: data['id']
      }

      data[:meta_content] = {
        import_type: IMPORT_TYPE[:place_id]
      }

      content = prepare_for_instagram(content, data)
      create content
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation => e
      return find_by(instagram_id: data['id'])
    end

    def prepare_for_instagram content, data
      content[:data] ||={}

      if data['images'].present?
        content[:url] = data['images']['standard_resolution']['url']
      end

      if data['videos'].present?
        content[:video_url] = data['videos']['standard_resolution']['url']
      end

      if data['caption'].present?
        content[:caption] = data['caption']['text']
      end

      if (location = data[:location]).present?
        if location[:latitude].present?
          content[:latitude] = location[:latitude]
          content[:longitude] = location[:longitude]
        end

        if location[:id].present?
          instagram_place_id = location[:id]
          place = InstagramPlace.create_for(instagram_place_id)
          if location[:name].present? && !place.name.present?
            place.update_attribute :name, location[:name]
          end
          content[:instagram_place_id] = instagram_place_id
        end
      end

      if data[:meta_content].present?
        content[:data][:meta_content] = data[:meta_content]
      end

      instagram_data = {}
      instagram_data[:tags] = data[:tags]
      instagram_data[:location] = data[:location]

      if data['likes'].present?
        instagram_data[:likes_count] = data['likes']['count']
      end

      if data['user'].present?
        instagram_data[:user] = data['user']
      end

      if data['comments'].present?
        instagram_data['comments'] = data['comments']['data'].map {|c| c['text']}
      end

      content[:data][:instagram] = instagram_data
      content
    end
  end

  def public_url
    file.present? ? file.url : url
  end

  def process_meta_data
    if url.present?
      self.update_attribute :meta_data, FaceDetector.analyze_photo_from_url(url)
    end
  end

  def import!
    if url.present? && !file.present?
      # process if photo is coming from twitter or instagram
      begin
        downloaded_file = FileDownloader.photo_from_url(url)
        if downloaded_file.present?
          meta_data = FaceDetector.analyze_photo_from_memory(downloaded_file.read)

          update_attributes({
            file: downloaded_file,
            meta_data: meta_data
          })
        end
      ensure
        downloaded_file.close if downloaded_file.present?
      end
    elsif meta_data == {} && file.present?
      # process if user uploaded the photo
      begin
        downloaded_file = FileDownloader.photo_from_url(file.url)
        if downloaded_file.present?
          meta_data = FaceDetector.analyze_photo_from_memory(downloaded_file.read)

          update_attributes({
            meta_data: meta_data
          })
        end
      ensure
        downloaded_file.close if downloaded_file.present?
      end
    end
  end

  def as_json(*)
    {
      id: id,
      url: public_url,
      kind: kind,
      caption: caption,
      created_at: created_at,
      meta_data: meta_data,
      venue_id: venue_id,
      event_ids: event_ids,
      performers_ids: performer_ids,
      user_id: user_id
    }
  end

  def get_post_type
    PostType::KIND.keys.each do |service|
      if kind == service.to_s
        return PostType::KIND[service]
      end
    end
  end

  def user_display_name
    if user.present?
      user.display_name
    elsif tweet.present?
      tweet.user_display_name
    elsif data.present? &&
       data['instagram'].present? &&
       (user_data = data['instagram']['user']).present?

      full_name = user_data['full_name']
      username = user_data['username']

      "#{full_name} (#{username})"
    end
  end

  def user_avatar_url
    if user.present?
      user.avatar.url(:medium)
    elsif tweet.present?
      tweet.user_avatar_url
    elsif data.present? &&
       data['instagram'].present? &&
       (user_data = data['instagram']['user']).present?

      user_data['profile_picture']
    end
  end

  def pos_json
    {
      id: id,
      url: public_url,
      caption: caption,
      kind: kind,
      display_name: user_display_name,
      avatar_url: user_avatar_url
    }
  end

  private
    def create_post
      if !standard? &&
         !twitter? &&
         latitude.present? &&
         longitude.present?

        Post.create_from_photo(self)
      end
    end

    def check_photo_import
      if instagram? || twitter? || standard?
        PhotoImportWorker.perform_later(self)
      end
    end

end

# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  url                :string
#  data               :json             default({})
#  venue_id           :integer
#  instagram_place_id :integer
#  service            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  instagram_id       :string
#  kind               :integer
#  video_url          :string
#  caption            :text
#  event              :integer
#  performer          :integer
#  meta_data          :jsonb
#  file_file_name     :string
#  file_content_type  :string
#  file_file_size     :integer
#  file_updated_at    :datetime
#  user_id            :integer
#  latitude           :decimal(, )
#  longitude          :decimal(, )
#  lonlat             :geography({:srid point, 4326
#  tweet_id           :integer
#
