
namespace :places do

	desc "Fill places from post coordinates"
	task :import_places => :environment do
		posts = Post.includes(:place).where("place_id IS NULL").all
		counter = 0
		reverse_geocoded = 0

		posts.each do |post|
			near_results = Place.near_to(post.longitude, post.latitude, 200).load

			if near_results.first.nil?
				new_place = post.reverse_geocode
				new_place.save
				post.place_id = new_place.id
				post.save
				reverse_geocoded += 1
			else
				post.place_id = near_results.first.id
				post.save
				counter += 1
			end
		end

		puts "Results: \n----------"
		puts "#{counter} imported."
		puts "#{reverse_geocoded} reverse geocoded."
	end

end