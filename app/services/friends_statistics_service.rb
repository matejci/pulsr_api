class FriendsStatisticsService
  def self.append!(data, current_user, id_attr = :id)
    events_ids = current_user.saved_events.starting_today.pluck(:id)
    venues_ids = current_user.saved_venues.pluck(:id)
    friends_ids = data.map { |row| row[id_attr] }.flatten

    events_count = UserAction.select('user_id, object_id').saved.starting_today.
                              where(user_id: friends_ids, object_type: 'Event', object_id: events_ids).
                              group('user_id').count('DISTINCT(user_id, object_id)')

    venues_count = UserAction.select('user_id, object_id').saved.
                              where(user_id: friends_ids, object_type: 'Venue', object_id: venues_ids).
                              group('user_id').count('DISTINCT(user_id, object_id)')

    data.each do |row|
      friend_id = row[id_attr]
      row.merge(common_events_count: events_count[friend_id].to_i, common_venues_count: venues_count[friend_id].to_i)
      row[:common_events_count] = friend_id.present? ? events_count[friend_id].to_i : 0
      row[:common_venues_count] = friend_id.present? ? venues_count[friend_id].to_i : 0
    end.sort_by!{ |row| row[:common_events_count] + row[:common_venues_count] }.reverse!
  end
end