module Actionable
  extend ActiveSupport::Concern

  included do
    has_many :user_actions, as: :object, dependent: :destroy
    has_many :saved_actions, -> { UserAction.saved }, as: :object, dependent: :destroy, class_name: 'UserAction'
    has_many :attending_actions, -> { UserAction.attend }, as: :object, dependent: :destroy, class_name: 'UserAction'
    has_many :not_attending_actions, -> { UserAction.not_attend }, as: :object, dependent: :destroy, class_name: 'UserAction'
    has_many :check_ins, -> { UserAction.check_in }, as: :object, dependent: :destroy, class_name: 'UserAction'
    has_many :saved_for_users, -> { UserAction.saved }, through: :user_actions, source: :user do
      def <<(user)
        unless proxy_association.owner.saved_for_users.find_by(id: user.id).present?
          super.<<(user)
        end
        proxy_association
      end
    end
    has_many :hidden_for_users, -> { UserAction.hidden }, through: :user_actions, source: :user do
      def <<(user)
        unless proxy_association.owner.hidden_for_users.find_by(id: user.id).present?
          super.<<(user)
        end
        proxy_association
      end
    end
    has_many :is_attending_users, -> { UserAction.attend }, through: :user_actions, source: :user do
      def <<(user)
        unless proxy_association.owner.attending_users.find_by(id: user.id).present?
          super.<<(user)
        end
        proxy_association
      end
    end
    has_many :maybe_attending_users, -> { UserAction.attend }, through: :user_actions, source: :user do
      def <<(user)
        unless proxy_association.owner.maybe_attending_users.find_by(id: user.id).present?
          super.<<(user)
        end
        proxy_association
      end
    end
    has_many :is_checked_in_users, -> { select("DISTINCT ON (users.id) users.*").merge(UserAction.check_in) }, through: :user_actions, source: :user do
      def <<(user, date = Time.current)
        unless proxy_association.owner.checked_in_users.find_by(id: user.id, date: date).present?
          super.create(user: user, starts_at: date)
        end
        proxy_association
      end

      def at_date(date)
        proxy_association.owner.checked_in_users.merge(UserAction.for_date(date))
      end
    end
  end

  # Going actions
  def attend_for_user user, date
    UserAction.attend_for_user(self, user, date)
  end

  # Not going actions
  def not_attending_for_user user, date
    UserAction.not_attending_for_user(self, user, date)
  end

  # Remove attendance
  def remove_attend_for_user user, date
    UserAction.remove_attend_for_user(self, user, date)
  end

  def attending_by? user, date
    attending_actions.for_date(date).
                      find_by(user: user).
                      present?
  end

  def not_attending_by? user, date
    not_attending_actions.for_date(date).
                          find_by(user: user).
                          present?
  end

  def attending_users date
    is_attending_users.merge(UserAction.for_date(date))
  end

  def attending_friends user, date
    attending_users(date).where(id: user.friends)
  end

  def attending_count date
    attending_users(date).count
  end

  def going_by? user, date
    if attending_by?(user, date)
      "going"
    elsif not_attending_by?(user, date)
      "not_going"
    else
      "pending"
    end
  end

  def is_liked_by?(user)
    user.liked?(self)
  end

  def is_disliked_by?(user)
    user.disliked?(self)
  end

  def voted_by? user
    case user.voted_as_when_voted_for(self)
    when true
      "like"
    when false
      "dislike"
    else
      "pending"
    end
  end

  # Check in actions
  def checked_in? user, date
    check_ins.as_user(user).for_date(date).present?
  end

  def checked_in_today? user
    checked_in? user, Time.current
  end

  def add_check_in user, date = Time.current
    UserAction.create_check_in(self, user, date)
  end

  def remove_check_in user, date
    UserAction.remove_check_in(self, user, date)
  end

  def checked_in_users date
    is_checked_in_users.merge(UserAction.for_date(date))
  end

  def checked_in_friends user, date
    checked_in_users(date).merge(UserAction.for_date(date)).where(id: user.friends)
  end

  def checked_in_count date
    check_ins.for_date(date).count
  end

  # Hidden actions

  def hidden_by? user
    hidden_for_users.find_by(id: user.id).present?
  end

  # Save actions
  def save_for_user user, date
    UserAction.create_save(self, user, date)
  end

  def remove_for_user user, date
    UserAction.remove_save(self, user, date)
  end

  def saved_by? user, date = nil
    if date.present?
      saved_for_users.merge(UserAction.for_date(date)).
                      find_by(id: user.id).
                      present?
    else
      saved_for_users.find_by(id: user.id).present?
    end
  end

  def saved_users date = nil
    if date.present?
      saved_for_users.merge(UserAction.for_date(date))
    else
      saved_for_users
    end
  end

  def saved_friends(user, date = nil)
    if user.present?
      if date.present?
        saved_for_users.merge(UserAction.for_date(date)).
          where(id: user.friends)
      else
        saved_for_users.where(id: user.friends)
      end
    else
      []
    end
  end

  def saved_count date = nil
    saved_for_users.count
  end

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

end
