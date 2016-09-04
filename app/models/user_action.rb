class UserAction < ActiveRecord::Base

  ACTIONS = {
    save: 'save',
    check_in: 'check_in',
    hide: 'hide',
    attend: 'attend',
    maybe_attend: 'maybe_attend',
    not_attending: 'not_attending',
    declined: 'declined'
  }.freeze

  OBJECT_SAVE = [ACTIONS[:save]].freeze

  scope :saved, -> { where(action: ACTIONS[:save])}
  scope :hidden, -> { where(action: ACTIONS[:hide])}
  scope :check_in, -> { where(action: ACTIONS[:check_in])}
  scope :attend, -> { where(action: ACTIONS[:attend])}
  scope :not_attend, -> { where(action: ACTIONS[:not_attending])}
  scope :maybe_attend, -> { where(action: ACTIONS[:maybe_attend])}
  scope :declined, -> { where(action: ACTIONS[:declined])}

  scope :for_date, -> date { where(starts_at: date.in_time_zone(Time.zone).beginning_of_day..date.in_time_zone(Time.zone).end_of_day) }
  scope :as_user, -> user { where(user: user) }
  scope :for_friends_of, -> user { where(user: user.friends) }
  scope :starting_today, -> { where(starts_at: Time.current.beginning_of_day..10.years.since) }
  scope :is_active, -> { where.not(starts_at: nil) }
  scope :starts_at, -> starts_at { where(starts_at: starts_at) }
  scope :visible_for_user, -> (user) {
    event_ids = Invitation.events.active.where(user: user).pluck(:invitable_id)
    event_ids += user.event_ids

    where("object_type = 'Venue' OR (object_type = 'Event' AND object_id IN (:event_ids))", {
      event_ids: event_ids
    })
  }


  belongs_to :user
  belongs_to :object, polymorphic: true

  def as_notification_json(options = {})
    case options[:reason]
    when Notification::REASON[:friends_save]
      {
        user_id: options[:data].try(:[], 'friend_id'),
        avatar: options[:data].try(:[], 'friend_avatar_url')
      }
    else
      {
        user_id: user_id,
        avatar: user.try(:avatar_url)
      }
    end
  end

  def self.get_offset_string(date = Time.now)
    minutes = date.in_time_zone(Time.zone).utc_offset/60
    result = ""

    if minutes < 0
      result << "-"
      minutes = minutes * -1
    else
      result << "+"
    end

    hours = minutes / 60
    minutes = minutes % 60

    result << (hours < 9 ? "0#{hours}" : hours)
    result << ":#{minutes < 9 ? '0' : '' }#{minutes}"
    result
  end

  def self.create_save object, user, date, options = {}
    object.saved_actions.
           merge(UserAction.for_date(date)).
           where(user_id: user.id).
           first_or_create(starts_at: date)

    Invitation.save_pending! object, user, date

    unless options[:type].present?
      options[:type] = "saved"

      EventSavedFriendsWorker.perform_later user, object, date, options
    end
  end

  def self.remove_save object, user, date
    object.saved_actions.
           merge(UserAction.for_date(date)).
           where(user_id: user.id).
           delete_all
  end

  #
  # Going to event
  #
  def self.attend_for_user object, user, date
    if object.is_a?(Event) && !object.timetables.for_date(date).present?
      raise Timetable::Exception, "Date for event attendance needs to have corresponding timetable starts_at"
    end

    options = {
      type: "attend"
    }

    not_attending_objects = object.not_attending_actions.
                                   merge(UserAction.for_date(date)).
                                   where(user_id: user.id)

    if not_attending_objects.present?
      not_attending_objects.update_all(action: ACTIONS[:attend])
    else
      object.attending_actions.
             merge(UserAction.for_date(date)).
             where(user_id: user.id).
             first_or_create(starts_at: date)

      EventSavedFriendsWorker.perform_later user, object, date, options
    end

    # Always save if you attend an object
    create_save(object, user, date, options)

    Invitation.attend_pending! object, user, date
  end

  #
  # Decline to attend it
  #
  def self.remove_attend_for_user object, user, date
    object.attending_actions.
           merge(UserAction.for_date(date)).
           where(user_id: user.id).
           delete_all

    object.not_attending_actions.
           merge(UserAction.for_date(date)).
           where(user_id: user.id).
           delete_all

    Invitation.remove_attend! object, user, date
  end

  #
  # Not going
  #
  def self.not_attending_for_user object, user, date
    attending_objects = object.attending_actions.
                               merge(UserAction.for_date(date)).
                               where(user_id: user.id)

    if attending_objects.present?
      attending_objects.update_all(action: ACTIONS[:not_attending])
    else
      object.not_attending_actions.
             merge(UserAction.for_date(date)).
             where(user_id: user.id).
             first_or_create(starts_at: date)
    end

    Invitation.not_attending_pending! object, user, date
  end

  def self.create_check_in(object, user, starts_at)
    unless object.checked_in?(user, starts_at)
      unless object.check_ins.as_user(user).present?
        create_save(object, user, date)
      end

      create(object: object, user: user, starts_at: starts_at, action: ACTIONS[:check_in])

      Invitation.pending.
                 where(invitable: object, invite_at: starts_at, user: user).
                 update_all(rsvp: Invitation::RESPONSE[:attend])
    end
  end

  def self.remove_check_in(object, user, starts_at)
    object.check_ins.as_user(user).for_date(starts_at).delete_all

    unless object.check_ins.as_user(user).present?
      object.saved_for_users.delete user
    end

    Invitation.pending.
               where(invitable: object, invite_at: starts_at, user: user).
               update_all(rsvp: Invitation::RESPONSE[:decline])
  end

  def self.saved_poi(user, options = {})
    options.reverse_merge!({
      page: 1,
      per_page: 30
    })

    query = where(action: OBJECT_SAVE).
              includes(:object).
              as_user(user).
              starting_today.
              order(:starts_at).
              page(options[:page]).
              per(options[:per_page])

    if options[:for_user].present?
      query = query.visible_for_user(options[:for_user])
    end

    query
  end

end

# == Schema Information
#
# Table name: user_actions
#
#  id          :integer          not null, primary key
#  object_id   :integer
#  object_type :string
#  user_id     :integer
#  action      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  starts_at   :datetime
#
