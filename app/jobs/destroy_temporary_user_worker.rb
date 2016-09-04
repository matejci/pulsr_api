class DestroyTemporaryUserWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(user)
    unless user.active?
      user.destroy
    end
  end
end