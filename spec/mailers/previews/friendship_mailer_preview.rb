# Preview all emails at http://localhost:3000/rails/mailers/friendship_mailer
class FriendshipMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/friendship_mailer/invite
  def invite
    FriendshipMailer.invite(User.first, Notification.first)
  end

end
