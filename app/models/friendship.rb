class Friendship < ActiveRecord::Base
  belongs_to :recipient, class_name: User
  belongs_to :sender, class_name: User
  has_many :notifications, as: :object, dependent: :destroy

  STATUS = {
    accepted: 1,
    pending: 2,
    requested: 3
  }

  STATUS.keys.each do |status|
    scope status, -> { where(status: STATUS[status])}
  end
  scope :active_friendship, -> { where(status: [STATUS[:accepted], STATUS[:pending]]) }

  def self.check_one_side(sender, recipient)
    find_by(sender: recipient, recipient: sender).present?
  end

  def self.exist?(sender, recipient)
    check_one_side(sender, recipient) && check_one_side(recipient, sender)
  end

  def self.find_friendship(sender, recipient)
    find_by(sender: recipient, recipient: sender)
  end

  def self.friend_request(sender, recipient, options = {})
    unless sender == recipient || exist?(sender, recipient)
      transaction do
        Friendship.create(sender: recipient, recipient: sender, status: STATUS[:pending], branch_url: options[:branch_url], invite_token: options[:invite_token])
        friendship = Friendship.create(sender: sender, recipient: recipient, status: STATUS[:requested], branch_url: options[:branch_url], invite_token: options[:invite_token])

        FriendRecommendation.clear_friend_recommendations(sender, recipient)
        unless options[:dont_send_notifications]
          Notification.create_friend_invitation(friendship, recipient)
        end
      end
    end
  end

  def self.accept_friendship(sender, recipient, options = {})
    transaction do
      pending_friendship = Friendship.find_friendship(sender, recipient)
      pending_friendship.accept!
      pending_friendship.notifications.
                         where(reason: Notification::REASON[:friendship]).
                         delete_all

      requested_friendship = Friendship.find_friendship(recipient, sender)
      requested_friendship.accept!
      requested_friendship.notifications.
                           where(reason: Notification::REASON[:friendship]).
                           delete_all


      FriendRecommendation.clear_friend_recommendations(sender, recipient)

      Contact.check_mutual_contact(sender, recipient)

      unless options[:dont_send_notifications]
        Notification.create_friend_accepted(requested_friendship, sender)
      end

    end

    Friendship::AcceptedWorker.set(wait_until: 15.seconds.from_now).
                               perform_later(recipient, sender)
  end

  def self.decline_request(sender, recipient)
    remove_friend(sender, recipient)
  end

  def self.remove_friend(sender, recipient)
    transaction do
      Friendship.find_friendship(sender, recipient).destroy
      Friendship.find_friendship(recipient, sender).destroy
    end

    Friendship::DeclinedWorker.set(wait_until: 15.seconds.from_now).
                               perform_later(recipient, sender)
  end

  def self.friends? sender, recipient
    where(sender: recipient, recipient: sender, status: STATUS[:accepted]).present?
  end

  def accept!
    update_attribute :status, STATUS[:accepted]
  end

  def status
    STATUS.each do |value, value_id|
      if value_id == attributes['status']
        return value
      end
    end
  end

  def decline_action
    Friendship.decline_request(sender, recipient)
  end

  def accept_action
    Friendship.accept_friendship(sender, recipient)
  end

  def opposite_user(user)
    sender == user ? recipient : sender
  end

  def as_notification_json(options = {})
    friend = opposite_user(options[:user])
    {
      user_id: friend.id,
      avatar: friend.avatar_url
    }
  end

  def full_branch_url
    url = branch_url

    if invite_token.present?
      url << "?invite_token=#{invite_token}" if !url.nil?
    end

    url
  end

end

# == Schema Information
#
# Table name: friendships
#
#  id           :integer          not null, primary key
#  sender_id    :integer
#  recipient_id :integer
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  branch_url   :string
#  invite_token :string
#
