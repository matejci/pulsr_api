class EventMailer < ApplicationMailer

	def invite(recipient, notification)

		@notification = notification
		@event = notification.object.invitable

		attachments.inline["pulsr-invite-envelope.png"] = File.read("#{Rails.root}/app/assets/images/mailers/onboarding_friendship/pulsr-invite-envelope.png")
		attachments.inline["pulsr-logotype.png"] = File.read("#{Rails.root}/app/assets/images/mailers/onboarding_friendship/pulsr-logotype.png")
		attachments.inline["icon-fb.png"] = File.read("#{Rails.root}/app/assets/images/mailers/onboarding_friendship/icon-fb.png")
		attachments.inline["icon-tw.png"] = File.read("#{Rails.root}/app/assets/images/mailers/onboarding_friendship/icon-tw.png")
		# attachments.inline["event-1.jpg"] = File.read("#{Rails.root}/app/assets/images/mailers/onboarding_friendship/event-1.jpg")

		mail(:to => recipient.email) do |format|
			format.html { render 'invite.html.erb' }
		end

	end

end
