class City < ActiveRecord::Base
  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :radius, presence: true

  has_many :tweets
  has_many :events
  has_many :venues

  geocoded_by latitude: :latitude, longitude: :longitude

  MAX_LEVEL = 7
  ABBREVIATIONS = {
    'Los Angeles' => 'LA',
    'San Francisco' => 'SF',
    'New York City' => 'NYC',
    'New York' => 'NYC',
    'Austin' => 'ATX',
    'Washington' => 'DC',
    'Atlanta' => 'ATL',
    'Boston' => 'BOS',
    'Chicago' => 'CHI',
    'Orlando' => 'ORL',
    'San Diego' => 'SD',
    'Detroit' => 'DET',
    'Miami' => 'MIA',
    'Phoenix' => 'PHX',
    'Memphis' => 'MEM'
  }
  ABBREVIATIONS_REGEX = /(#{City::ABBREVIATIONS.keys.join('|')})/i
  ABBREVIATIONS_SPACE_REGEX = /\ ?(#{City::ABBREVIATIONS.keys.join('|')})\ ?/i

  scope :with_boundaries, -> { where.not(boundaries: nil) }
  scope :with_timezone, -> { where.not(timezone: nil) }

  def twitter_stream_boundary
    if boundaries.present?
      bl = boundaries['bottom']['left']
      tr = boundaries['top']['right']
      [bl['longitude'], bl['latitude'], tr['longitude'], tr['latitude']]
    end
  end

  def boundary_corners
    bl = boundaries['bottom']['left']
    tr = boundaries['top']['right']

    {
      top: tr['latitude'],
      bottom: bl['latitude'],
      left: tr['longitude'],
      right: bl['latitude']
    }
  end

  def within_city latitude, longitude
    if boundaries.present?
      bl = boundaries['bottom']['left']
      tr = boundaries['top']['right']

      bl['longitude'] < longitude && tr['longitude'] > longitude &&
      bl['latitude'] < latitude && tr['latitude'] > latitude
    else
      false
    end
  end

  def update_top_tastes
    result = []
    Taste.all.each do |taste|
      venue_count = taste.venues_by_zone(self, limit_size: 10000).count
      event_count = taste.events_by_zone(self, limit_size: 10000).
                          upcoming.
                          distinct(:id).count

      result << [taste.id, venue_count + event_count]
    end

    self.data['taste_ids'] = result.sort_by! {|item| item.last}.map(&:first).reverse
    self.data['tastes_by_category'] = {
      events: get_event_tastes,
      food_and_drinks: get_food_and_drinks_tastes,
      other: get_other_tastes
    }

    self.save

    self.data['taste_ids']
  end

  def get_event_tastes
    list = top_tastes.events
    response = []
    self.data['taste_ids'].each do |id|
      if (taste = list.find {|t| t.id == id}).present?
        response << taste
      end
    end

    response
  end

  def get_food_and_drinks_tastes
    list = top_tastes.food_and_drinks
    response = []
    self.data['taste_ids'].each do |id|
      if (taste = list.find {|t| t.id == id}).present?
        response << taste
      end
    end

    response
  end

  def get_other_tastes
    list = top_tastes.other
    response = []
    self.data['taste_ids'].each do |id|
      if (taste = list.find {|t| t.id == id}).present?
        response << taste
      end
    end

    response
  end

  def top_taste_ids
    if data['taste_ids'].present?
      data['taste_ids']
    else
      update_top_tastes
    end
  end

  def top_tastes
    Taste.where(id: top_taste_ids)
  end

  def tastes_by_category
    if self.data['tastes_by_category'].present?
      self.data['tastes_by_category']
    else
      {
        events: top_tastes.events,
        food_and_drinks: top_tastes.food_and_drinks,
        other: top_tastes.other
      }
    end
  end

  def self.update_top_tastes
    City.with_boundaries.each do |city|
      city.update_top_tastes
    end
  end

  def self.abbreviation_for(city_name)
    name = city_name
      .split.map(&:downcase)
      .map(&:capitalize).join(' ')

    ABBREVIATIONS[name]
  end

  def self.city_for_tweet cities, tweet
    if tweet.is_a?(ActiveRecord::Base) && tweet.city_id.present?

      return cities.detect do |city|
        city.id == tweet.city_id
      end
    elsif tweet.is_a?(Twitter::Tweet)
      coordinates = tweet.to_hash[:coordinates]

      if coordinates.present?
        latitude = coordinates[:coordinates][1]
        longitude = coordinates[:coordinates][0]

        return cities.detect do |city|
          city.within_city(latitude, longitude)
        end
      end
    elsif tweet.is_a?(Hash)
      tweet = tweet.symbolize_keys

      if tweet[:latitude].present? && tweet[:longitude].present?
        return cities.detect do |city|
          city.within_city(tweet[:latitude], tweet[:longitude])
        end
      end
    end

    return nil
  end

  def self.nearest_city(latitude, longitude, options = {})
    options.reverse_merge!({
      radius: 500
    })

    near([latitude, longitude], options[:radius]).first
  end

  def get_venues
    Venue.within(get_edges)
  end

  def get_edges
    bl = boundaries['bottom']['left']
    tr = boundaries['top']['right']

    {
      left: bl['longitude'],
      right: tr['longitude'],
      top: tr['latitude'],
      bottom: bl['latitude']
    }
  end

  def city_mapper options = {}
    options = {
      max_level: MAX_LEVEL
    }.merge(options.merge(get_edges))

    Twitter::Node.new(options)
  end
end

# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  name       :string
#  latitude   :decimal(10, 6)
#  longitude  :decimal(10, 6)
#  radius     :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  boundaries :json
#  location   :point            point, 0
#  timezone   :string
#
