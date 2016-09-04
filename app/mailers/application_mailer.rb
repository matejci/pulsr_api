class ApplicationMailer < ActionMailer::Base
	include Roadie::Rails::Automatic
  layout 'mailer'
  helper MailerHelper

  default from: 'Pulsr <no-reply@pulsr.com>'
end
