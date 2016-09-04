class ReportService

	def self.send_report_email(post, reported_by)
		ReportMailer.report_offensive_post(post, reported_by).deliver_now
	end

	def self.send_block_user_email(user, reported_by)
		ReportMailer.blocked_user(user, reported_by).deliver_now
	end

end