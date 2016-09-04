namespace :push do
  desc "Setup the push clients"
  task setup: :environment do
    PushNotification.setup
  end
end