class Performer < ActiveRecord::Base
  include Createable
  include Taggable

  belongs_to :user
  has_and_belongs_to_many :events, -> { select("DISTINCT ON (events.id) events.*") }
  has_many :photo_objects, as: :object, dependent: :destroy
  has_many :photos, through: :photo_objects

  validates :eventful_id, uniqueness: { message: "ID has already been taken", allow_blank: true, allow_nil: true }

  scope :unprocessed, -> { where(processed_at: nil) }
  scope :processed, -> { where.not(processed_at: nil) }
  scope :has_twitter, -> { where.not(twitter: nil) }

  update_index('search#venue') { events.map(&:venue) }
  update_index('search#event') { events }

  class << self
    def update_twitter_username offset = 0
      options = {
        batch_size: TwitterClient::SEARCH_BATCH_SIZE
      }

      unprocessed.find_in_batches(options) do |group|
        group.each do |performer|
          delay = (offset * 15).minutes

          Twitter::PerformerWorker
            .set(wait: delay)
            .perform_later(performer)
        end

        offset += 1
      end

      offset
    end

    def create_from_eventful(data, event = nil)
      values = {}

      {
        eventful_id: 'id',
        eventful_url: 'url',
        name: 'name',
        short_bio: 'short_bio',
        long_bio: 'long_bio'
      }.each do |to, from|
        values[to] = data[from] if data[from].present?
      end

      values[:created_by] = Performer::CREATED_BY_EVENTFUL

      values['images'] = Eventful::Core.extract_images(data)
      values['links'] = Eventful::Core.extract_links(data)

      performer = create! values
      Tagging.process_eventful_tags(data["tags"]["tag"], performer) if data["tags"].present?

      event.performers << performer if event.present? && event.is_a?(Event)

      performer

      performer
    rescue ActiveRecord::RecordInvalid => e
      performer = where(eventful_id: data['id']).first
    ensure
      performer
    end
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

  def update_from_eventful(data)
    values = {}

    {
      name: 'name',
      short_bio: 'short_bio',
      long_bio: 'long_bio'
    }.each do |to, from|
      if data[from].present? && data[from] != attributes[to]
        values[to] = data[from]
      end
    end

    update_attributes values
  end

  def twitter_data
    data['twitter'] || data[:twitter]
  end

  def scores
    data['twitter_scores'] || data[:twitter_scores]
  end

  def update_twitter_username
    Twitter::Performer.new(self).process
  end

  def get_instagram_user_id!
    instagram = Instagram::PhotoImporter.find_user_for_performer(self)
    update_attributes instagram: instagram if instagram.present?
  end
end

# == Schema Information
#
# Table name: performers
#
#  id           :integer          not null, primary key
#  eventful_id  :string
#  eventful_url :string
#  name         :string
#  short_bio    :text
#  long_bio     :text
#  links        :json
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  images       :string           default([]), is an Array
#  processed_at :datetime
#  twitter      :string
#  data         :json             default({})
#  url          :string
#  created_by   :string
#  instagram    :string
#  user_id      :integer
#
