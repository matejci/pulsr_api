class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, class_name: 'User'
  belongs_to :invitable, polymorphic: true
  has_many :notifications, as: :object, dependent: :destroy

  RESPONSE = {
    attend: 'attend',
    maybe_attend: 'maybe_attend',
    decline: 'decline',
    pending: 'pending',
    save: 'save'
  }

  scope :saved, -> { where(rsvp: RESPONSE[:save])}
  scope :attending, -> { where(rsvp: RESPONSE[:attend])}
  scope :maybe_attending, -> { where(rsvp: RESPONSE[:maybe_attend])}
  scope :declined, -> { where(rsvp: RESPONSE[:decline])}
  scope :pending, -> { active.where(rsvp: RESPONSE[:pending]) }
  scope :active, -> { where(invite_at: (Time.current.beginning_of_day)..10.years.since) }
  scope :expired, -> { where(invite_at: (10.years.ago..1.day.ago)) }

  scope :events, -> { where(invitable_type: 'Event') }
  scope :venues, -> { where(invitable_type: 'Venue') }

  before_create :set_as_pending
  after_create :prepare_notification

  def self.create_invitation(invitable, sender, user, options = {})
    options.assert_valid_keys(:invite_at, :branch_url, :invite_token)

    invitations = where({
      sender: sender,
      user: user,
      invitable: invitable,
      invite_at: options[:invite_at],
      branch_url: options[:branch_url]
    })

    if invitations.present?
      invitation = invitations.first

      if invitation.rsvp == RESPONSE[:decline]
        invitation.notifications.delete_all
        invitation.send_notification

        invitation.update_attributes rsvp: RESPONSE[:pending]
      end

      invitation
    else
      invitations.first_or_create(options)
    end
  end

  def self.save_pending! invitable, user, date
    pending.where(invitable: invitable, invite_at: date, user: user).
            update_all(rsvp: RESPONSE[:save])
  end

  def self.attend_pending! invitable, user, date
    invitations = where(invitable: invitable, invite_at: date, user: user)
    invitations.update_all(rsvp: RESPONSE[:attend])

    invitations.each do |invitation|
      invitation.notifications.delete_all
    end

    if (invitation = invitations.first).present?
      creator_id = invitation.invitable.user_id

      if user.friend_ids.include?(creator_id)
        Notification.create_invitation_accepted(invitation)
      end
    end

    invitations
  end

  def self.not_attending_pending! invitable, user, date
    invitations = where(invitable: invitable, invite_at: date, user: user)
    invitations.update_all(rsvp: RESPONSE[:not_attending])

    where(invitable: invitable, invite_at: date, user: user).each do |invitation|
      invitation.notifications.delete_all
    end

    invitations
  end

  def self.remove_attend! invitable, user, date
    invitations = where(invitable: invitable, invite_at: date, user: user)
    invitations.update_all(rsvp: RESPONSE[:pending])

    invitations.each do |invitation|
      invitation.notifications.delete_all
    end

    invitations
  end

  def accept_invitation!
    case invitable
    when Event
      if invitable.private?
        # If private mark for attending and saving
        invitable.attend_for_user(user, invite_at)
        update_attributes(rsvp: RESPONSE[:attend])
      else
        # if public only save the event
        invitable.save_for_user(user, invite_at)
        update_attributes(rsvp: RESPONSE[:save])
      end

    when Venue
      invitable.save_for_user(user, invite_at)
      update_attributes(rsvp: RESPONSE[:save])
    end


  end

  def dismiss_invitation!
    update_attributes(rsvp: RESPONSE[:decline])
  end

  def accept_action
    accept_invitation!
  end

  def decline_action
    dismiss_invitation!
  end

  def send_notification
    if notifications.count == 0
      send(:prepare_notification)
    end
  end

  def can_send_notification?
    (user.active? && sender.friends_with?(user))
  end

  def as_notification_json(options = {})
    data = {
      object_id: invitable_id,
      object_type: invitable_type,
      invite_at: invite_at,
      user_id: sender.id,
      avatar: sender.avatar_url
    }

    case invitable
    when Event
      data[:is_private] = invitable.private?
    when Venue
      # Venue specific data
    end

    data
  end

  def full_branch_url
    url = branch_url

    if invite_token.present?
      url << "?invite_token=#{invite_token}" if !url.nil?
    end

    url
  end

  private
    def set_as_pending
      self.rsvp = RESPONSE[:pending]
    end

    #
    # Notify the user only in case they are already friends with
    # otherwise send friendship request first
    #
    def prepare_notification
      notification = case invitable
      when Event
        Notification.create_event_invitation(self)
      when Venue
        Notification.create_venue_invitation(self)
      end

      unless notification.present?
        options = {
          invite_token: invite_token,
          branch_url: branch_url
        }

        # send friendship request first
        # if it doesn't have connection
        sender.add_friend(user, options)
      end
    end
end

# == Schema Information
#
# Table name: invitations
#
#  id             :integer          not null, primary key
#  invitable_id   :integer
#  invitable_type :string
#  user_id        :integer
#  sender_id      :integer
#  message        :text
#  invite_at      :datetime
#  rsvp           :string
#  invitation_key :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  branch_url     :string
#  invite_token   :string
#
