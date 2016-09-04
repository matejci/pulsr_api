require "celluloid"
require "sidekiq/custom_fetch"

Sidekiq.configure_server do |config|
  Sidekiq.options[:fetch] = Sidekiq::CustomFetch

  config.redis = { url: ENV['REDIS_PATH'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_PATH'] }
end