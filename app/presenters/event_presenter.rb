class EventPresenter
  attr_accessor :event, :user, :date, :recommendation

  def self.prepare_with_date(event, user = nil, date = Time.current, coordinates = nil)

    recommendation = EventVenueRecommendationService.recommendation(event, user, coordinates) if user.present?

    data = {
      event: event,
      user: user,
      date: date,
      recommendation: recommendation
    }

    new(data)
  end

  def initialize data = {}
    @event = data[:event]
    @user = data[:user]
    @date = data[:date]
    @show_class_type = data[:show_class_type]
    @recommendation = data[:recommendation]
  end

  def venue
    @venue ||= event.venue
  end

  def timetable
    @timetable ||= event.timetables.upcoming(date).first
  end

  def as_json(options = {})
    data_hash = {
      id: event.id,
      name: event.name,
      description: event.description,
      photos: event.photo_collection,
      location: {
        latitude: event.latitude,
        longitude: event.longitude
      },
      tags: event.tags.is_public,
      user_id: event.user.try(:id),
      created_by: event.created_by,
      kind: event.kind,
      starts_at: timetable.try(:starts_at),
      ends_at: timetable.try(:ends_at),
      like_count: event.cached_votes_up,
      dislike_count: event.cached_votes_down,
      like_score: event.cached_weighted_score,
      recommendation: recommendation
    }

    if venue.present?
      location = data_hash[:location]
      location[:street_address] = venue.street_address
      location[:city] = venue.city
      location[:region] = venue.region
      location[:zip_code] = venue.zip_code
      location[:country] = venue.country
      location[:name] = venue.name
      location[:venue_id] = venue.id
      location[:telephone_number] = venue.telephone_number
      data_hash[:location] = location
    end

    if event.private?

    end

    if user.present?
      if user == event.user
        data_hash[:friends_can_invite] = event.friends_can_invite
      end
      data_hash[:is_invited] = user.invited_to_event?(event, date)
      data_hash[:can_invite] = event.user_can_invite?(user)
      data_hash[:saved] = event.saved_by?(user, date)
      data_hash[:going] = event.going_by?(user, date)
      data_hash[:liked] = event.voted_by?(user)
      data_hash[:hidden] = event.hidden_by?(user)
    end

    data_hash
  end
end