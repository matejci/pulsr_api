class ReportMailer < ActionMailer::Base

	default from: "no-reply@pulsr.com"
	default to: "reports@pulsr.com"

	def report_offensive_post(post, reported_by)
		@post = Post.find(post)
		@reported_by = User.find(reported_by)
		mail(subject: "Post reported as being offensive")
	end

	def blocked_user(user, reported_by)
		@user = User.find(user)
		@reported_by = User.find(reported_by)
		mail(subject: "Blocked user report")
	end

end