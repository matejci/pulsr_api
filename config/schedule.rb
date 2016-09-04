# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every 1.day, roles: [:twitter_realtime] do
  rake "twitter:prune_old_tweets"
end

# every 1.day do
#   rake "eventful:process_new_events"
# end

every 1.day, roles: [:data_import] do
  rake "eventful:process_pending_venues"
end

every 1.day, roles: [:data_import] do
  rake "instagram:process_event_photos"
end

every 1.day, roles: [:data_import] do
  rake "friendship:clear_expired_notifications"
end

every '0 6 * * 0,1,3,4,5,6', roles: [:eventful_api] do
  rake "eventful:daily_import_api"
end

every '0 6 * * 2', roles: [:eventful_api] do
  rake "eventful:weekly_import_api"
end

every 1.day, roles: [:recommendation_zoning] do
  rake "recommendation:zone_venues"
end

every 1.day, roles: [:recommendation_zoning] do
  rake "recommendation:zone_events"
end

every 1.day, roles: [:recommendation_zoning] do
  rake "recommendation:daily_processing"
end

every 1.day, roles: [:recommendation_zoning] do
  rake "recommendation:clear_old_data"
end

every 1.week, roles: [:recommendation_zoning] do
  rake "tastes:process_by_city"
end


# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
