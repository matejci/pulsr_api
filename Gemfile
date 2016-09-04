source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
ruby '2.2.2'

gem 'rails', '4.2.5'
# Use sqlite3 as the database for Active Record
gem 'composite_primary_keys'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.

gem 'dotenv-rails'
gem 'kaminari'
gem 'paperclip'
gem 'aws-sdk', '< 2.0'
gem 'twilio-ruby'
gem 'mandrill-api'

# Sending push notifications
gem 'rpush'

gem 'geocoder'
gem 'httpclient'

# gem 'parallel'
# gem 'thread'

gem 'concurrent-ruby', require: 'concurrent'
gem 'dropbox-sdk', require: 'dropbox_sdk'
gem 'activerecord-import'
gem 'squeel'
gem 'instagram'
gem 'celluloid'
gem 'sidekiq', '~> 4'
gem 'sidekiq-limit_fetch'
gem 'redis_rate_limiter'
gem 'sinatra'
gem 'smarter_csv'
gem 'saxerator'

# Redis client
gem 'redis'
gem 'redis-rails'
gem 'redis-rack-cache'

gem 'whenever'

# zip code into time zone
gem 'tzip'

gem 'tweetstream'
gem 'eventfulapi'
gem 'oauth'
gem 'twitter'
gem 'geo-distance'
gem 'rack-cors', :require => 'rack/cors'
gem 'nokogiri'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'clipboard'
  gem 'spork-rails'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'awesome_print'
  gem 'pry-rails'
  gem 'hirb'
  gem 'factory_girl_rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'letter_opener'
end

# For image processing
gem 'ruby-opencv'

gem 'bootstrap-sass'
gem 'devise'
gem 'cancan'
gem 'haml-rails'
gem 'pg'
gem 'activerecord-postgis-adapter'
gem 'rgeo-activerecord'
gem 'rgeo'

# database replication
gem 'ar-octopus', require: 'octopus'

gem 'koala'
gem 'acts_as_votable', '~> 0.10.0'
gem 'roadie-rails', '~> 1.0'
gem 'chewy'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_20]
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', github: "capistrano/rvm"
  gem 'capistrano3-unicorn'
  gem 'capistrano-ops_works'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_apps_pages'
  gem 'rails_apps_testing'
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rails_db'
  gem 'annotate'
end

group :development, :test do
  gem 'spring-commands-rspec'
  gem 'faker'
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'thin'
end

group :production do
  gem 'unicorn'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end