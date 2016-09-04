class FriendRecommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, class_name: User
  has_many :notifications, as: :object, dependent: :destroy

  REASON = {
    contact_book: 1,
    recommended: 2,
    sent_invitation: 3
  }.freeze

  ACTION = {
    friendship_invitation: 1,
    accept_friendship: 2,
    event_invitation: 3
  }.freeze

  STATUS = {
    pending: 1,
    accept: 2,
    decline: 3
  }

  scope :pending, -> { where(status: STATUS[:pending]) }
  scope :accepted, -> { where(status: STATUS[:accept]) }
  scope :declined, -> { where(status: STATUS[:decline]) }
  scope :active, -> { pending }

  class << self
    def add_recommendation(user, contact)
      unless user.friend_recommendations.where(contact: contact).present?
        recommendation = create({
          user: user,
          contact: contact,
          reason: REASON[:contact_book],
          action: ACTION[:friendship_invitation],
          status: STATUS[:pending]
        })

        Notification.create_user_contact_joined(recommendation, user)
        recommendation
      end
    end

    #
    # Send in case there is existing pulsr user that matches with
    # contact values in your contact book
    #
    def add_existing(user, contact)
      unless user.friend_recommendations.where(contact: contact).present?
        recommendation = create({
          user: user,
          contact: contact,
          reason: REASON[:contact_book],
          action: ACTION[:friendship_invitation],
          status: STATUS[:pending]
        })

        Notification.create_contact_is_user(recommendation, user)
        recommendation
      end
    end

    def clear_friend_recommendations(sender, recipient)
      recommendations = []
      recommendations += FriendRecommendation.where(user: sender, contact: recipient)
      recommendations += FriendRecommendation.where(user: recipient, contact: sender)

      recommendations.each do |recommendation|
        recommendation.notifications.each do |notification|
          notification.accept!
        end
        recommendation.accept!
      end
    end
  end

  def decline_action
    decline!
  end

  def accept_action
    user.add_friend(contact)
    accept!
  end

  def decline!
    update_attribute :status, STATUS[:decline]
  end

  def accept!
    update_attribute :status, STATUS[:accept]
  end

  def as_notification_json(options = {})
    {
      user_id: contact_id,
      avatar: contact.avatar_url
    }
  end
end

# == Schema Information
#
# Table name: friend_recommendations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  contact_id :integer
#  reason     :integer
#  action     :integer
#  status     :integer
#  status_at  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
