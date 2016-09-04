namespace :friendship do
  desc "Clear expired notifications"
  task clear_expired_notifications: :environment do
    Invitation.expired.find_each do |invitation|
      invitation.notifications.delete_all
    end
  end
end