class RateLimiter
  CLIENT = RedisClient.server
  INSTAGRAM_LIMIT = 1250 # 5000 hourly
  INSTAGRAM_PERIOD = 900 # seconds
  USERNAME_SEARCH_TWITTER_LIMIT = 180
  TWITTER_PERIOD = 900 # seconds

  INSTAGRAM_KEY = "insta_#{ENV['INSTAGRAM_API_KEY']}"
  SEARCH_TWITTER_KEY = "twitter_#{ENV['TWITTER_CONSUMER_KEY']}"

  SEARCH_TWITTER_QUEUE = "twitter_search"
  INSTAGRAM_QUEUE = "instagram"

  class << self
    def instagram_limiter
      options = {
        limit: INSTAGRAM_LIMIT - 15,
        interval: INSTAGRAM_PERIOD
      }
      @instagram_limiter ||= RedisRateLimiter.new("instagram_limiter", CLIENT, options)
    end

    def search_twitter_limiter
      options = {
        limit: USERNAME_SEARCH_TWITTER_LIMIT - 15,
        interval: TWITTER_PERIOD
      }
      @search_twitter_limiter ||= RedisRateLimiter.new("search_twitter_limiter", CLIENT, options)
    end

    def add_twitter_user_search
      instagram_limiter.add(SEARCH_TWITTER_KEY).first
    end

    def twitter_user_search_limited?
      instagram_limiter.exceeded?(SEARCH_TWITTER_KEY)
    end

    def twitter_user_search_retry_in?
      instagram_limiter.retry_in?(SEARCH_TWITTER_KEY)
    end

    def add_instagram_limit
      instagram_limiter.add(INSTAGRAM_KEY).first
    end

    def instagram_limited?
      instagram_limiter.exceeded?(INSTAGRAM_KEY)
    end

    def instagram_retry_in?
      instagram_limiter.retry_in?(INSTAGRAM_KEY)
    end
  end
end