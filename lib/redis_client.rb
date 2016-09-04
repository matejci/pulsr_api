# lib/redis_client.rb

require "redis"

class RedisClient

  # polling time for a specific event
  POLLING_TIME = 2.hours

  class << self
    def server config = RedisConfig
      @@server ||= Redis.new(config)
    end

    def pubsub config = RedisConfig
      @@pubsub ||= Redis.new(config)
    end

    def publish_to_tweet_with_city tweet
      channel_key = RedisClient.tweet_with_city_channel_name
      data = tweet.to_stream_json
      RedisClient.server.publish channel_key, data.to_json
    end

    def subscribe_to_tweet_with_city_stream
      channel_key = RedisClient.tweet_with_city_channel_name

      RedisClient.pubsub.subscribe(channel_key) do |on|
        on.message do |channel, content|
          yield(JSON.parse(content)) if block_given?
        end
      end
    end

    def publish_to_twitter_stream tweet, options = {}
      channel_key = RedisClient.tweet_stream_channel_name
      data = tweet.to_stream_json
      data['place_name'] = options[:place_name] if options[:place_name].present?

      RedisClient.server.publish channel_key, data.to_json
    end

    def subscribe_to_twitter_stream
      channel_key = RedisClient.tweet_stream_channel_name

      RedisClient.pubsub.subscribe(channel_key) do |on|
        on.message do |channel, content|
          yield(JSON.parse(content)) if block_given?
        end
      end
    end

    def extract_json data
      json_content = nil

      if data.is_a? Array
        json_content = data.map { |tweet| extract_json_tweet(tweet)  }
      else
        json_content = [extract_json_tweet(data)]
      end

      json_content
    end

    def extract_json_tweet tweet
      {
        id: tweet.id,
        id_str: tweet.id.to_s,
        created_at: tweet.created_at,
        screen_name: tweet.user.screen_name,
        profile_image_url: tweet.user.profile_image_url.to_s,
        text: tweet.text
      }
    end

    def tweet_with_city_channel_name
      "event:twitter_channel"
    end

    def tweet_stream_channel_name
      "event:twitter_stream_channel"
    end

    def all_channels_for_event
      "event:*:*"
    end
  end
end