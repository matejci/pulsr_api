namespace :testing do
	desc "Import Tweets from staging"
	task import_tweets_to_process: :environment do

		require 'csv'

		file = "#{Rails.root}/public/tweets_to_process.csv"

		tweets = Tweet.where("text like ?", "%https://t.co%").limit(20)

		CSV.open(file, 'w') do |writer|
			tweets.each do |tweet|
				writer << [tweet.data]
			end
		end

		puts "Import to file '#{file}' completed."

	end

end