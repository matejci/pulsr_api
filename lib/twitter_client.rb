class TwitterClient
  include Singleton

  SEARCH_BATCH_SIZE = 180

  URL_REGEX = /(?:https?:\/\/)?(?:www\.)?twitter\.com\/(?:(?:\w)*#!\/)?(?:pages\/|intent\/user\S(?:screen_name|user_id)=)?(?:([\w\-]*)(?:\/status\/[\w\-]*)?|(?:[\w\-]*\/)*([\w\-]*))/i

  # Venues with city name in the title need to do two API calls, thus half the limit of the regular one
  SEARCH_HALF_BATCH_SIZE = SEARCH_BATCH_SIZE / 2

  def search(query, options = {})
    RateLimiter.add_twitter_user_search
    client.user_search(query, options)
  end

  def search_performer(query, options = {})
    client.user_search(query, options)
  end

  def search_venue(query, options = {})
    client.user_search(query, options)
  end

  def user_timeline(username, options = {})
    client.user_timeline(username).map &:to_hash
  end

  def user_timelines(usernames, options = {})
    usernames.map {|username| user_timeline(username, options)}
  end

  def extract_username text
    candidates = text.scan(TwitterClient::URL_REGEX).flatten
    candidates.reject {|x| /^widget|share/ === x}.first
  end

  private

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end
  end
end