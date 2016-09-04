class Friendship::DeclinedWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(recipient, sender)
    recipient.invitations(sender: sender).delete_all
    sender.invitations(sender: recipient).delete_all
  end
end