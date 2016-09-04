class PointOfInterest < ActiveRecord::Base
  include Locationable

  belongs_to :object, polymorphic: true
  belongs_to :zone, class_name: City, foreign_key: 'zone_id'

  scope :for_date, -> date, upto = nil do
    date = Date.parse(date).in_time_zone(Time.zone) if date.is_a? String
    upto = if upto.present?
      if upto.is_a? ActiveSupport::Duration
        date + upto
      else
        upto
      end
    else
      date
    end

    where(starts_at: (date.in_time_zone(Time.zone).beginning_of_day)..(upto.in_time_zone(Time.zone).end_of_day))
  end
  scope :events, -> { where(object_type: 'Event' )}
  scope :venues, -> { where(object_type: 'Venue' )}
  scope :is_public, -> { where(public: true) }
  scope :with_private_events_for_user, -> (user) {
    events.with_private_for_user(user)
  }
  scope :with_private_for_user, -> (user) {
    event_ids = Invitation.events.active.where(user: user).pluck(:invitable_id)
    event_ids += user.event_ids

    where("public = true OR (data->>'event_id')::int IN (:event_ids)", {
      event_ids: event_ids
    })
  }
  scope :recommended_for_user, -> (user) {
    taste_sql = user.taste_data_sql
    if taste_sql.present?
      select("*, #{user.taste_data_sql}").order("position DESC")
    else
      all
    end
  }

  delegate :photos, to: :object

  attr_accessor :photo_url, :ends_at, :rank, :saved

  class << self
    def clean_objects_until(date = 7.days)
      where(starts_at: (10.years.ago)..(date.ago)).delete_all
    end

    def actions_into_poi(user, options = {})
      options.reverse_merge!({
        page: 1,
        per_page: 30
      })

      user_actions = UserAction.saved_poi(user, options)
      data = {
        current_page: options[:page],
        total_pages: user_actions.total_pages,
        total_count: user_actions.total_count
      }

      data[:points] = user_actions.map do |user_action|
        object = user_action.object

        if object.is_a?(Venue)
          object.instance_variable_set(:@starts_at, user_action.starts_at)

          def object.starts_at
            @starts_at
          end
        elsif object.is_a?(Event)
          object.starts_at = user_action.starts_at
        end

        if options.has_key? :saved_objects
          object.instance_variable_set(:@saved, options[:saved_objects])
        end

        object
      end

      data[:points] = PointOfInterest.build_objects(data[:points], user, saved: true)

      data
    end

    def build_objects data, user = nil, options = {}
      data.map { |item| item.to_pos(user, options) }
    end

    def order_by_proximity pois, latitude, longitude, offset = 0

    end

    def explore(latitude, longitude, options = {})
      query = for_date(options[:date]).
        by_location(latitude, longitude, Locationable::EXTENDED_SEARCH_RADIUS).order("weight DESC").
        page(options[:page]).per(options[:items_per_page])

      if options[:user].present?
        query = query.with_private_for_user(options[:user]).
          recommended_for_user(options[:user])
      else
        query = query.is_public
      end

      query
    end

    def explore_venues(latitude, longitude, options = {})
      options[:items_per_page] = options[:venues_per_page].to_i
      explore(latitude, longitude, options).venues
    end

    def explore_events(latitude, longitude, options = {})
      options[:items_per_page] = options[:events_per_page].to_i
      explore(latitude, longitude, options).events
    end

    def recommend(zone, options)
      query = for_date(options[:date]).
        where(zone: zone).
        page(options[:page]).
        per(options[:per_page])

      if options[:user].present?
        query = query.with_private_for_user(options[:user]).
          recommended_for_user(options[:user])
      else
        query = query.is_public
      end

      query
    end

    def recommend_venues(zone, options)
      recommend(zone, options).venues
    end

    def recommend_events(zone, options)
      recommend(zone, options).events
    end

    def process_objects(pois, options = {})
      user = options[:user]

      saved_venue_ids = user.saved_venues.merge(UserAction.starting_today).map(&:id)
      saved_event_ids = user.saved_events.merge(UserAction.starting_today).map(&:id)

      pois.each_with_index do |poi, index|
        poi.saved = case poi.object_type
        when "Event"
          saved_event_ids.include?(poi.object_id)
        when "Venue"
          saved_venue_ids.include?(poi.object_id)
        else
          false
        end

        current_page = options[:page].to_i
        per_page = options[:per_page].to_i
        poi.rank = index + 1 + ((current_page - 1) * per_page)
      end

      pois
    end
  end

  def as_json(options = {})
    response = {
      name: name,
      latitude: latitude,
      longitude: longitude,
      type: object_type.downcase,
      photo: photo,
      starts_at: starts_at,
      data: data,
      street_address: street_address,
      city: city,
      region: region,
      zip_code: zip_code,
      country: country,
      rank: rank || 0,
      saved: saved,
      weight: weight,
      id: id
    }

    case object_type
    when "Venue"
      response.merge!({
        opening_hours: opening_hours
      })
    when "Event"
      response.merge!({
        venue_name: venue_name
      })
    end

    response
  end
end

# == Schema Information
#
# Table name: point_of_interests
#
#  id             :integer          not null, primary key
#  name           :string
#  latitude       :decimal(10, 6)
#  longitude      :decimal(10, 6)
#  taste_data     :jsonb
#  data           :jsonb
#  starts_at      :datetime
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  object_id      :integer
#  object_type    :string
#  lonlat         :geography({:srid point, 4326
#  street_address :string
#  city           :string
#  region         :string
#  zip_code       :string
#  country        :string
#  opening_hours  :json
#  photo          :json
#  venue_name     :string
#  zone_id        :integer
#  public         :boolean
#
