class EventSavedFriendsWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(user, object, date, options = {})
    if options[:type].present?
      options[:type] = options[:type].to_sym

      friend_actions = case options[:type]
      when :saved
        object.saved_actions
      when :attend
        object.attending_actions
      end

      friend_actions = friend_actions.merge(UserAction.for_date(date)).
                                      where(user_id: user.friends)

      data = {
        friend_id: user.id,
        friend_avatar_url: user.avatar_url,
        friend_display_name: user.display_name,
        friend_type: options[:type]
      }

      friend_actions.each do |user_action|
        Notification.friend_saved(user_action.user, user_action, data)
      end

    end
  end
end
