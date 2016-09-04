module Friendable
  extend ActiveSupport::Concern

  included do
    has_many :friendships, foreign_key: :sender_id, class_name: Friendship, dependent: :destroy
    # All mutuall accepted friendships
    has_many :friends, -> { Friendship.accepted }, through: :friendships, source: :recipient
    # All friendship requests sent to your contacts
    has_many :requested_friends, -> { Friendship.requested }, through: :friendships, source: :recipient
    # All friendship requests that you need to accept from other users
    has_many :pending_friends, -> { Friendship.pending }, through: :friendships, source: :recipient
    has_many :active_friends, -> { Friendship.active_friendship }, through: :friendships, source: :recipient
  end

  def friend_request(friend)
    Friendship.friend_request(self, friend)
  end

  def accept_request(friend)
    Friendship.accept_friendship(self, friend)
  end

  def decline_request(friend)
    Friendship.decline_request(self, friend)
  end

  def remove_friend(friend)
    Friendship.remove_friend(self, friend)
  end

  def friends_with?(friend)
    Friendship.friends? self, friend
  end

  def self.serch_for_user(data)
    User.find_by(phone_number: data[:phone_number])
  end

  def send_friendship_invitation(data)
    user = User.search_for_user(data)

    unless user.present?
      user = User.create_temporary_user(data)
    end

    friend_request(user)

    user
  end
end