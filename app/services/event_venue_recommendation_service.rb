class EventVenueRecommendationService

  def self.recommendation(recommendation_object, user, coordinates = nil)

    user_tastes = user.tastes.pluck(:title).compact.uniq
    object_tastes = recommendation_object.tastes.pluck(:title).compact.uniq
    object_coordinates = [recommendation_object.latitude, recommendation_object.longitude]
    distance = coordinates.nil? ? nil : Geocoder::Calculations.distance_between(coordinates, object_coordinates)

    if object_tastes.empty? || user_tastes.empty?
      recommendation = distance.nil? ? nil : "This " << "#{recommendation_object.class}".downcase << " is within #{distance.to_i} miles of current location."
    else
      tastes = user_tastes & object_tastes
      recommendation = distance.nil? ? "#{recommendation_object.class} is recommended because you selected #{tastes.to_sentence} as interests."
                                     : "#{recommendation_object.class} is recommended because you selected #{tastes.to_sentence} as interests,
                                        and you are #{distance.to_i} miles away from this #{recommendation_object.class}."
    end
  end

end