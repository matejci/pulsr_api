class Taste < ActiveRecord::Base
  belongs_to :taste_category
  has_many :user_tastes
  has_many :users, through: :user_tastes
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :categories
  has_many :photo_objects, as: :object, dependent: :destroy
  has_many :photos, through: :photo_objects, as: :object

  scope :events, -> { where(taste_category_id: TasteCategory::LIST['Event']).order(:title) }
  scope :other, -> { where(taste_category_id: TasteCategory::LIST['Non-food and drink location']).order(:title) }
  scope :food_and_drinks, -> { where(taste_category_id: TasteCategory::LIST['Food and Drink location']).order(:title) }

  has_attached_file :profile_photo, :styles => {
    thumb: '200x200>',
    medium: '350x350>'
  }
  validates_attachment :profile_photo, content_type: {
    content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  }

  TASTE_COUNT = Taste.count

  def self.tastes_by_category zone = nil
    if zone.present?
      zone.tastes_by_category
    else
      {
        events: events,
        food_and_drinks: food_and_drinks,
        other: other
      }
    end
  end

  def self.get_users_taste(user)
    if user.tastes.present?
      user.tastes.order("RANDOM()").first
    else
      Taste.order("RANDOM()").first
    end
  end

  def as_json(*)
    {
      id: id,
      title: title,
      description: description,
      taste_category_id: taste_category_id,
      photo_url: profile_photo.present? ? profile_photo.url : nil
    }
  end

  def venues_by_zone(zone, options = {})
    options.reverse_merge!({
      limit_size: 5000
    })

    Venue.where(["id IN
      ((
        SELECT DISTINCT ON (venues.id) venues.id
        FROM venues
        INNER JOIN categories_venues
          ON categories_venues.venue_id = venues.id
        WHERE categories_venues.zone_id = :zone_id AND
              categories_venues.category_id IN (:category_ids)
        LIMIT :limit_size
      )
      UNION
      (
        SELECT DISTINCT ON (venues.id) venues.id
        FROM venues
        INNER JOIN taggings
          ON taggings.taggable_id = venues.id AND
             taggings.taggable_type = 'Venue'
        WHERE taggings.zone_id = :zone_id AND
              taggings.tag_id IN (:tag_ids)
        LIMIT :limit_size
      ))",
      {
        category_ids: category_ids,
        tag_ids: tag_ids,
        taste_id: self.id,
        zone_id: zone.id,
        limit_size: options[:limit_size]
      }]
    )
  end

  def events_by_zone(zone, options = {})
    options.reverse_merge!({
      limit_size: 5000
    })

    events.where(taggings: {zone_id: zone.id}).limit(options[:limit_size])
  end

  def events
    Event.joins(:taggings).where(taggings: {tag_id: tag_ids})
  end

end

# == Schema Information
#
# Table name: tastes
#
#  id                         :integer          not null, primary key
#  name                       :string
#  taste_category_id          :integer
#  description                :text
#  example                    :text
#  title                      :string
#  import_string              :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  profile_photo_file_name    :string
#  profile_photo_content_type :string
#  profile_photo_file_size    :integer
#  profile_photo_updated_at   :datetime
#
