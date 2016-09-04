class Friendship::AcceptedWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(recipient, sender)
    recipient.invitations(sender: sender).map(&:send_notification)
    sender.invitations(sender: recipient).map(&:send_notification)
  end
end