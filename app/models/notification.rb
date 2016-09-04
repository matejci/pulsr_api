require 'action_view'

class Notification < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :object, polymorphic: true
  belongs_to :user

  REASON = {
    contact_book: 1,
    friend_recommendation: 2,
    contact_joined: 3,
    contact_is_user: 4,
    event_invitation: 5,
    friendship: 6,
    cannot_send_notification: 7,
    venue_invitation: 8,
    onboarding_friendship: 9,
    friendship_batch: 10,
    friendship_accepted: 11,
    friends_save: 12,
    invitation_accepted: 13
  }.freeze

  ACTION = {
    send_friendship_invitation: 1,
    save_event: 2,
    accept_friendship: 3,
    dismiss: 4,
    save_venue: 5
  }.freeze

  STATUS = {
    pending: 1,
    accept: 2,
    decline: 3,
    dismiss: 4
  }.freeze

  scope :pending, -> { where(status: STATUS[:pending]) }
  scope :accepted, -> { where(status: STATUS[:accept]) }
  scope :declined, -> { where(status: STATUS[:decline]) }
  scope :active, -> { pending }

  SMS_MESSAGES = {
    REASON[:onboarding_friendship] => -> {
      "%s says you two often go to %s. " \
      " Pulsr is a great way to find %s and more! " \
      "Download Pulsr to find cool things to do, events, and hangout spots %s" % [
        get_sender_display_name,
        Taste.get_users_taste(get_sender),
        Taste.get_users_taste(get_sender),
        object.full_branch_url
      ]
    },
    REASON[:friendship] => -> {
      "%s wants to find cool stuff to do with you on Pulsr! " \
      "Download Pulsr to find cool things to do, events, and hangout spots. %s" % [
        get_sender_display_name,
        object.full_branch_url.nil?  ? "http://pulsr.com" : object.full_branch_url
      ]
    },
    REASON[:event_invitation] => -> {
      "%s has invited you to %s. Check it out on Pulsr. %s" % [
        get_sender_display_name,
        object.invitable.name,
        object.full_branch_url
      ]
    },
    REASON[:venue_invitation] => -> {
      "%s has invited you go to %s on %s. Check it out on Pulsr. %s" % [
        get_sender_display_name,
        object.invitable.name,
        object.invite_at.to_date.to_s(:short),
        object.full_branch_url
      ]
    }
  }

  PUSH_MESSAGES = {
    REASON[:friendship_accepted] => -> {
      "%s has accepted your friendship request." % [
        get_sender_display_name
      ]
    },
    REASON[:friendship] => -> {
      "%s has shared their collection with you! Slide to connect with them." % [
        get_sender_display_name
      ]
    },
    REASON[:friendship_batch] => -> (contacts_count) {
      "#{contacts_count} of your contacts are also on Pulsr! Slide to connect with them."
    },
    REASON[:contact_joined] => -> {
      "%s is also on Pulsr! Slide to connect with them." % [
        get_sender_display_name
      ]
    },
    REASON[:contact_is_user] => -> {
      ("%s is also on Pulsr! Share your Collection " \
      "with them so you guys can find cool stuff to do together.") % [
        get_sender_display_name
      ]
    },
    REASON[:event_invitation] => -> {
      "%s invited you to this %s ago. %s" % [
        get_sender_display_name,
        time_ago_in_words(object.created_at),
        object.invitable.name
      ]
    },
    REASON[:friend_recommendation] => -> {
      ("%s is also on Pulsr! Share your Collection with them " \
      "so you guys can find cool stuff to do together.") % [
        get_sender_display_name
      ]
    },
    REASON[:cannot_send_notification] => -> {
      # error sending notification
    },
    REASON[:venue_invitation] => -> {
      "%s has invited you go to %s on %s" % [
        get_sender_display_name,
        object.invitable.name,
        object.invite_at.to_date.to_s(:short)
      ]
    },
    REASON[:invitation_accepted] => -> {
      "%s has accepted your invitation to %s on %s" % [
        get_sender_display_name,
        object.invitable.name,
        object.invite_at.to_date.to_s(:short)
      ]
    }
  }

  IN_APP_MESSAGES = {
    REASON[:friendship_accepted] => -> {
      "%s has accepted your friendship request." % [
        get_sender_display_name
      ]
    },
    REASON[:friendship] => -> {
      "%s has shared their collection with you. " \
      "Share your Collection with them so you guys can find cool stuff to do together." % [
        get_sender_display_name
      ]
    },
    REASON[:contact_joined] => -> {
      "%s is also on Pulsr! Share your Collection with " \
      "them so you guys can find cool stuff to do together. " % [
        get_sender_display_name
      ]
    },
    REASON[:contact_is_user] => -> {
      ("%s is also on Pulsr! Share your Collection " \
      "with them so you guys can find cool stuff to do together.") % [
        get_sender_display_name
      ]
    },
    REASON[:event_invitation] => -> {
      "%s invited you to this %s ago. %s" % [
        get_sender_display_name,
        time_ago_in_words(object.created_at),
        object.invitable.name
      ]
    },
    REASON[:friend_recommendation] => -> {
      ("%s is also on Pulsr! Share your Collection with them " \
      "so you guys can find cool stuff to do together.") % [
        get_sender_display_name
      ]
    },
    REASON[:cannot_send_notification] => -> {
      # error sending notification
    },
    REASON[:venue_invitation] => -> {
      "%s has invited you go to %s on %s" % [
        get_sender_display_name,
        object.invitable.name,
        object.invite_at.to_date.to_s(:short)
      ]
    },
    REASON[:friends_save] => -> {
      case data['friend_type']
      when 'saved'
        "%s has also saved the %s on %s" % [
          data['friend_display_name'],
          object.object.name,
          object.starts_at.to_s(:short)
        ]
      when 'attend'
        "%s is also attending the %s on %s" % [
          data['friend_display_name'],
          object.object.name,
          object.starts_at.to_s(:short)
        ]
      else
        ""
      end
    },
    REASON[:invitation_accepted] => -> {
      "%s has accepted your invitation to %s on %s" % [
        get_sender_display_name,
        object.invitable.name,
        object.invite_at.to_date.to_s(:short)
      ]
    }
  }

  class << self
    #
    # Notification to send when the invited contact is missing
    # or the phone number or email is not valid to be sent to
    # them.
    #
    def create_missing_contact_details(contact, user)
      notification = create(
        user: user,
        object: contact,
        reason: REASON[:contact_cannot_send_notifications],
        action: ACTION[:dismiss],
        status: STATUS[:pending]
      )
      notification.send_notification
      notification
    end

    #
    # Notification when a user has registered that has the same details
    # as your contact detail like phone number or email
    #
    def create_user_contact_joined(friend_recommendation, user)
      notification = create(
        user: user,
        object: friend_recommendation,
        reason: REASON[:contact_joined],
        action: ACTION[:send_friendship_invitation],
        status: STATUS[:pending]
      )
      notification.send_notification
      notification
    end

    #
    # Notification when a contact has the user that uses same personal information
    #
    def create_contact_is_user(friend_recommendation, user)
      notification = create(
        user: user,
        object: friend_recommendation,
        reason: REASON[:contact_is_user],
        action: ACTION[:send_friendship_invitation],
        status: STATUS[:pending]
      )
      notification
    end

    #
    # Notification when a user has sent you a request to be friends with you
    #
    def create_friend_invitation(friendship, user)
      notification = create(
        user: user,
        object: friendship,
        reason: REASON[:friendship],
        action: ACTION[:accept_friendship],
        status: STATUS[:pending]
      )
      notification.send_notification(true)
      notification
    end

    #
    # Notification when a user has accepted your friendship request
    #
    def create_friend_accepted(friendship, user)
      notification = create(
        user: user,
        object: friendship,
        reason: REASON[:friendship_accepted],
        action: ACTION[:dismiss],
        status: STATUS[:pending]
      )
      notification.send_notification
      notification
    end

    #
    # Notification when a user has been invited to an event
    #
    def create_event_invitation(event_invitation)
      if event_invitation.can_send_notification?

        notification = create(
          user: event_invitation.user,
          object: event_invitation,
          reason: REASON[:event_invitation],
          action: ACTION[:save_event],
          status: STATUS[:pending]
        )
        notification.send_notification(true)
        notification
      end
    end

    #
    # Notification when a friend saves something which user has also saved
    #
    def friend_saved(user, object, data = {})
      notification = create(
          user: user,
          object: object,
          reason: REASON[:friends_save],
          action: ACTION[:dismiss],
          status: STATUS[:pending],
          data: data
      )
      notification.send_notification
      notification
    end

    #
    # Notification when a user has been invited into a venue
    #
    def create_venue_invitation(venue_invitation)
      if venue_invitation.can_send_notification?

        notification = create(
          user: venue_invitation.user,
          object: venue_invitation,
          reason: REASON[:venue_invitation],
          action: ACTION[:save_venue],
          status: STATUS[:pending]
        )
        notification.send_notification(true)
        notification
      end
    end

    #
    # Notification when a user has accepted your invitation request
    #
    def create_invitation_accepted(invitation)
      notification = create(
        user: invitation.invitable.user_id,
        object: invitation,
        reason: REASON[:invitation_accepted],
        action: ACTION[:dismiss],
        status: STATUS[:pending]
      )
      notification.send_notification
      notification
    end

    #
    # Send on contact import to check for recommendations
    #
    def batch_contact_processing_notification(user, starts_at)
      recommendations = user.friend_recommendations.where(created_at: starts_at..1.minute.since)

      if recommendations.count == 1
        notification = recommendations.first.notifications.first
        notification.send_notification
      elsif recommendations.count > 1
        message = instance_exec recommendations.count, &PUSH_MESSAGES[REASON[:friendship_batch]]

        PushNotification.send_message(user, message)
      end
    end

    #
    # Send confirmation code for the phone number
    # confirmation
    #
    def send_phone_number_code(user)
      if user.temp_phone_number.present?
        body = "Your Pulsr phone number verification code is:#{user.phone_number_token}"
        TwilioClient.send_sms(user.temp_phone_number, body)
      end
    end

  end

  def get_contact

  end

  def get_recipient
    user
  end

  def get_sender
    case reason
    when REASON[:onboarding_friendship]
      object.opposite_user(user)
    when REASON[:friendship_accepted]
      object.opposite_user(user)
    when REASON[:friendship]
      object.opposite_user(user)
    when REASON[:event_invitation]
      object.sender
    when REASON[:venue_invitation]
      object.sender
    when REASON[:contact_joined]
      object.contact
    when REASON[:contact_is_user]
      object.contact
    when REASON[:friend_recommendation]
      object.contact
    when REASON[:friends_save]
      object.user
    when REASON[:invitation_accepted]
      object.user
    end
  end

  def get_sender_display_name
    sender_display_name = get_sender.try(:display_name)

    if sender_display_name.present?
      sender_display_name
    elsif (contact_list = get_sender.get_as_contact_objects_for(user)).present?
      if (contact = contact_list.first).present?
        contact.display_name
      end
    else
      get_sender.try(:email)
    end
  end

  def send_notification can_send_as_sms = false
    if object.present? && user.present?
      if user.can_push_notifications?
        send_push_notification
      elsif user.can_send_sms? && can_send_as_sms && !user.active?

        Failure.create({
          name: "SMS",
          data: {
            notification: self
          }
        })

        send_sms_notification

      elsif user.can_send_email?

        Failure.create({
          name: "EMAIL",
          data: {
            notification: self
          }
        })

        send_email_notification
      else
        # TODO user has no means to communicate with
        # Raise error notification
        #
        # Notification.create_missing_contact_details(get_contact, user)
      end
    end
  end

  def send_push_notification
    if can_send_push_notification?
      PushNotification.send_notification_to(user, self)
    end
  end

  def can_send_push_notification?
    %i{friendship_accepted
       friendship
       friendship_batch
       contact_joined
       contact_is_user
       event_invitation
       friend_recommendation
       cannot_send_notification
       venue_invitation}.any? {|key| REASON[key] == reason }
  end

  def send_sms_notification
    if %i{onboarding_friendship
          friendship
          event_invitation
          venue_invitation}.any? {|key| REASON[key] == reason }

      content = get_sms_message
      recipient = get_recipient

      if recipient.present? && recipient.phone_number.present?
        TwilioClient.send_sms(recipient.phone_number, content)
      else
        # TODO exception recipient missing or no phone number
      end
    end
  end

  def send_email_notification
    if %i{onboarding_friendship
          friendship
          event_invitation
          venue_invitation}.any? {|key| REASON[key] == reason }

      case reason
      when REASON[:onboarding_friendship]
        OnboardingFriendshipMailer.invite(user, self).deliver_later
      when REASON[:friendship]
        FriendshipMailer.invite(user, self).deliver_later
      when REASON[:event_invitation]
        EventMailer.invite(user, self).deliver_later
      when REASON[:venue_invitation]
        VenueMailer.invite(user, self).deliver_later
      end

    end
  end

  def update_action(response_action)
    case response_action
    when :decline
      if action == ACTION[:dismiss]
        dismiss!
      else
        object.decline_action
        decline!
      end

    when :accept
      if action == ACTION[:dismiss]
        dismiss!
      else
        object.accept_action
        accept!
      end
    when :dismiss
      if can_dismiss?
        dismiss!
      end
    end
  end

  def can_dismiss?
    [REASON[:event_invitation], REASON[:venue_invitation]].any? { |r| reason == r }
  end

  def dismiss!
    update_attribute :status, STATUS[:dismiss]
  end

  def decline!
    update_attribute :status, STATUS[:decline]
  end

  def accept!
    update_attribute :status, STATUS[:accept]
  end

  def get_sms_message
    instance_exec &SMS_MESSAGES[reason]
  end

  def prepare_title
    instance_exec &IN_APP_MESSAGES[reason]
  end

  def reason_to_string
    result = Notification::REASON.select{|key, value| value == reason }
    if result.present?
      result.keys.first
    end
  end

  def push_title
    instance_exec &PUSH_MESSAGES[reason]
  end

  def push_json
    {}.tap do |data|
      if object.present?
        data[:notification_id] = self.id
      end
    end
  end

  def as_json(*)
    {
      id: id,
      title: prepare_title,
      reason: reason_to_string,
      data: object.as_notification_json(user: user, data: data, reason: reason)
    }
  end

end

# == Schema Information
#
# Table name: notifications
#
#  id          :integer          not null, primary key
#  object_id   :integer
#  object_type :string
#  user_id     :integer
#  reason      :integer
#  status      :integer
#  action      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  data        :jsonb
#
