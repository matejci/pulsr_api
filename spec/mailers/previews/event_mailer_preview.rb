# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/event_mailer/invite
  def invite
    notification = Notification.where(reason: Notification::REASON[:event_invitation]).first
    user = User.first

    EventMailer.invite(user, notification)
  end

end
