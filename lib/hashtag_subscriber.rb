class HashtagSubscriber
  class << self
    def run
      RedisClient.subscribe_to_twitter_stream do |tweet|
        process_hashtags tweet
        process_usernames tweet
      end
    end

    def process_hashtags tweet
      scan_for_hashtags(tweet["text"]).each do |hashtag|
        Hashtag
          .where(name: hashtag.downcase, city_name: tweet['place_name'], period: TimePeriod.now)
          .first_or_create.tap do |tag|
          Hashtag.increment_counter(:counter, tag.id)
        end
      end
    end

    def process_usernames tweet
      scan_for_username(tweet["text"]).each do |username|
        Hashtag
          .where(name: username.downcase, city_name: tweet['place_name'], period: TimePeriod.now, is_username: true)
          .first_or_create.tap do |tag|
          Hashtag.increment_counter(:counter, tag.id)
        end
      end
    end

    def scan_for_username tweet
      # username
      regex = /^@?(\w){1,15}$/
      tweet.scan(regex).flatten.map &:downcase
    end

    def scan_for_hashtags tweet
      # hashtag
      regex = /(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/
      hashtags = tweet.scan(regex).flatten.map &:downcase


      filter(hashtags)
    end

    def filter hashtags
      hashtags.reject {|tag| bad_words.include? tag }
    end

    def bad_words
      @@bad_words ||= %w(job jobs hiring careerarc hospitality)
    end
  end
end