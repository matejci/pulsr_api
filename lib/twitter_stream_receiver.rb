require 'dotenv'
Dotenv.load

require 'tweetstream'

ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(root, "config", "environment")

cities = City.with_boundaries
boundaries = cities.map(&:twitter_stream_boundary).compact.flatten

TweetStream::Client.new.locations(*boundaries) do |status|
  options = {}

  city = City.city_for_tweet(cities, status)
  options[:city_id] = city.id if city.present?

  tweet = Tweet.create_from_twitter(status, options)

  if city.present?
    RedisClient.publish_to_tweet_with_city(tweet)
  end
  RedisClient.publish_to_twitter_stream(tweet, place_name: status.place.full_name)
end