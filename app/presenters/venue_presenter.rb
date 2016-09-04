class VenuePresenter
  attr_accessor :venue, :user, :date, :recommendation

  def self.prepare_with_date(venue, user = nil, date = Time.current, coordinates = nil)

    recommendation = EventVenueRecommendationService.recommendation(venue, user, coordinates) if user.present?

    data = {
      venue: venue,
      user: user,
      date: date,
      recommendation: recommendation
    }

    new(data)
  end

  def self.prepare_with_user venue, user = nil
    data = {
      venue: venue,
      user: user
    }

    new(data)
  end

  def initialize(options = {})
    @venue = options[:venue]
    @user = options[:user]
    @date = options[:date] || Time.current
    @recommendation = options[:recommendation]
  end

  def as_json(options = {})
    data_hash = {
      id: venue.id,
      name: venue.name,
      description: venue.description,
      latitude: venue.latitude,
      longitude: venue.longitude,
      street_address: venue.street_address,
      city: venue.city,
      region: venue.region,
      zip_code: venue.zip_code,
      country: venue.country,
      photos: venue.photo_collection,
      opening_hours: venue.hours,
      telephone_number: venue.telephone_number,
      user_id: venue.user.try(:id),
      created_by: venue.created_by,
      tags: venue.tags.is_public,
      like_count: venue.cached_votes_up,
      dislike_count: venue.cached_votes_down,
      like_score: venue.cached_weighted_score,
      url: venue.url,
      recommendation: recommendation
    }

    if user.present?
      data_hash[:saved] = venue.saved_by?(user, date)
      data_hash[:hidden] = venue.hidden_by?(user)
      data_hash[:liked] = venue.voted_by?(user)
    end

    data_hash
  end
end