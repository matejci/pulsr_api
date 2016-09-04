require 'json'

module Twitter
  class Processor
    attr_accessor :cities, :mappers

    def self.new_all_cities
      new(City.all)
    end

    def initialize cities
      cities = cities.to_a if cities.is_a? City::ActiveRecord_Relation
      @cities = [cities] unless cities.is_a? Array
      @cities = cities
      @mappers = {}
      prepare
    end

    def prepare
      cities.select! {|city| city.boundaries.present? }
      cities.each do |city|
        prepare_city(city)
        puts "City #{city.name} prepared"
      end
    end

    def prepare_city city
      @mappers[city.name] = city.city_mapper
    end

    def mapper_for(city)
      @mappers[city.name]
    end

    def process_today options = {}
      process_period(1.day.ago..Time.now, options)
    end

    def process_period period, options = {}
      ::Tweet.has_city.where(created_at: period).find_in_batches do |group|
        process_tweets(group)
      end
    end

    def process_tweet tweet
      tweet = tweet.symbolize_keys if tweet.is_a?(Hash)
      process_tweets(tweet)
    end

    def process_tweets tweets
      tweets = tweets.to_a if tweets.is_a? ActiveRecord::Relation
      tweets = [tweets] unless tweets.is_a? Array

      tweets.each do |tweet|
        city = City.city_for_tweet(@cities, tweet)

        mapper_for(city).add_tweet(tweet) if city.present?
      end
    end

    def clear_counters!
      @mappers.each do |city, mapper|
        mapper.reset_counting!
      end
    end

    def details_for_city city
      mapper_for(city).non_empty_leaves
    end

    def details_for_cities
      cities.map do |city|
        details_for_city(city)
      end.flatten
    end

    def prepare_for_db
      details_for_cities.map &:to_tweet_activity
    end

    def prepare_for_db!
      details_for_cities.map &:to_tweet_activity!
    end

    def save_json_file path = "tmp/temp"
      data = details_for_cities.map &:to_json_file

      File.open(path + '.json', "w") do |f|
        f.write(data.to_json)
      end

      cities.map do |city|
        data = details_for_city(city).map &:to_json_file

        File.open(path + "-#{city.name.parameterize}.json", "w") do |f|
          f.write(data.to_json)
        end
      end
    end

  end
end
