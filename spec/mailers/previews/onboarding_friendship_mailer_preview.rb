# Preview all emails at http://localhost:3000/rails/mailers/onboarding_friendship_mailer
class OnboardingFriendshipMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/onboarding_friendship_mailer/invite
  def invite
    OnboardingFriendshipMailer.invite(User.first, Notification.first)
  end

end
