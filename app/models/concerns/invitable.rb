module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, -> { Invitation.pending }, as: :invitable, dependent: :destroy
    has_many :pending_users, through: :invitations, source: :user
  end

  def create_invitation(sender, user, invite_at)
    options = {
      invite_at: invite_at
    }
    Invitation.create_invitation(self, sender, user, options)
  end

  def decline_invitation(invitation_id)
    invitations.find_by(id: invitation_id).dismiss_invitation!
  end

  def accept_invitation(invitation_id)
    invitations.find_by(id: invitation_id).accept_invitation!
  end

  def invite_contacts(contacts, sender, options)
    if contacts.first.is_a?(Contact) && contacts.last.is_a?(Contact)
      users = contacts.map(&:get_contact_user).compact

      invite_users(users, sender, options)
    else
      contacts.each do |contact_data|
        if contact_data.is_a?(Contact) && contact_data.get_contact_user.present?
          invite_user(contact_data.get_contact_user, sender, options.dup)
        else
          dup_options = options.dup
          dup_options[:invite_token] = contact_data[:invite_token]
          contact = contact_data[:contact]

          if contact.get_contact_user.present?
            invite_user(contact.get_contact_user, sender, dup_options)
          end
        end
      end
    end
  end

  def invite_user(user, sender, options)
    options.assert_valid_keys(:invite_at, :branch_url, :invite_token)

    sender.invite_friend(user, self, options)
  end

  def invite_users(users, sender, options)
    options.assert_valid_keys(:invite_at, :branch_url)

    users.each do |user|
      sender.invite_friend(user, self, options.dup)
    end
  end

end