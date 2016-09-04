namespace :twitter do
  desc "Twitter stream receiver"
  task stream: :environment do
    ruby 'lib/twitter_stream_receiver.rb'
  end

  desc "Process tweets for last 24 hours"
  task process_24h: :environment do
    processor = Twitter::Processor.new_all_cities
    processor.process_today
    processor.save_json_file
    puts "TweetActivity saved to ./tmp/temp.json"
  end

  desc "Realtime Process for Tweets"
  task realtime_process: :environment do
    TweetSubscriber.run
  end

  desc "Hashtag Processing for Tweets"
  task hashtag: :environment do
    HashtagSubscriber.run
  end

  desc "Prune old tweet data"
  task prune_old_tweets: :environment do
    Tweet.where("created_at < :date", {date: 5.days.ago}).delete_all
    TweetActivity.where("created_at < :date", {date: 6.hours.ago}).delete_all

    puts "Older data has been destroyed"
  end

  desc "Update Twitter Usernames"
  task update_usernames: :environment do
    offset = 0
    offset = Performer.update_twitter_username(offset)
    offset = Venue.update_twitter_username(offset)
  end
end