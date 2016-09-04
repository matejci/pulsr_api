class OnboardingFriendshipMailer < ApplicationMailer

  def invite(recipient, notification)
    @notification = notification
  	@onboarding_events = Event.onboarding_events(notification.get_sender, recipient)

    mail to: recipient.email
  end

end
