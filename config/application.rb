require File.expand_path('../boot', __FILE__)
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ActiveSupport::JSON::Encoding.time_precision = 0

module PulsrApi
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.view_specs false
      g.helper_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end

    #TODO -> specify correct origin, once admin app is live
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :delete, :put, :patch, :options, :head], :max_age => 0
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app/services')
    config.autoload_paths << Rails.root.join('app/chewy')
    # config.autoload_paths << Rails.root.join('app/controllers/api/concerns')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    #Redis caching
    #config.cache_store = :redis_store, ENV['REDIS_DEV_CACHE_PATH'], { expires_in: 90.minutes }
    config.cache_store = :redis_store, ENV['REDIS_DEV_CACHE_PATH']


    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.paperclip_defaults = {
      :storage => :s3,
      :s3_credentials => {
        :bucket => ENV['S3_BUCKET_NAME'],
        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
      }
    }

    config.active_record.schema_format = :sql

    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      authentication: :plain,
      domain: ENV.fetch("SMTP_DOMAIN"),
      enable_starttls_auto: true,
      password: ENV.fetch("SMTP_PASSWORD"),
      port: "587",
      user_name: ENV.fetch("SMTP_USERNAME")
    }

    config.action_mailer.default_url_options = { host: ENV["SMTP_DOMAIN"] }

  end

end
