namespace :diagnostics do
  desc "Process Evenftul event data"
  task eventful_city_data: :environment do
    begin
      City.all.map(&:name).each do |city_name|
        puts city_name
        counter = 0
        EventfulClient.search_by_location(city_name) do |event|
          counter += 1
          puts counter
        end
      end
    rescue Psych::SyntaxError => e
      Failure.create(name: 'Eventful city event api', error: e.message)
    end
  end

  desc "Clear Sidekiq data"
  task clear_sidekiq: :environment do
    Sidekiq.redis { |r| puts r.flushall }
  end
end