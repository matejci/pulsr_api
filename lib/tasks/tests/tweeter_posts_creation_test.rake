namespace :testing do
	desc "Create posts from tweets"
	task create_posts_from_tweets: :environment do

		require 'csv'

		cities = City.with_boundaries
		boundaries = cities.map(&:twitter_stream_boundary).compact.flatten

		csv_file_path = "#{Rails.root}/public/tweets_to_process.csv"
		csv_file = open(csv_file_path, 'r')
		csv_options = { chunk_size: 100 }

		CSV.foreach(csv_file, headers: false) do |row|

			options = {}

			parsed_row = eval(row[0])
			parsed_row = parsed_row.deep_symbolize_keys

			city = City.city_for_tweet(cities, parsed_row)
			options[:city_id] = city.id if city.present?

			tweet = Tweet.create_from_twitter(parsed_row, options)

		end

		puts "Finished."

	end

end