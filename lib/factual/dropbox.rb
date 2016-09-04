class Factual::Dropbox
  @@client ||= DropboxClient.new ENV['DROPBOX_OAUTH_TOKEN']

  FOLDER = '/pulsr'

  DIFF_RESTAURANTS_REGEX = /^\/pulsr\/us_restaurants.v3_(\d{2}).batch_diff.\d+.tab.gz/
  RESTAURANTS_REGEX = /^\/pulsr\/us_restaurants.factual.v3_(\d{2}).\d+.tab.gz/
  DIFF_PLACES_REGEX = /^\/pulsr\/us_places.v3_(\d{2}).batch_diff.\d+.tab.gz/
  PLACES_REGEX = /^\/pulsr\/us_places.factual.v3_(\d{2}).\d+.tab.gz/
  INSTAGRAM_REGEX = /\/pulsr\/pulsr_us_crosswalk.factual.\d{4}_\d{2}_\d{2}.\d+.tab.gz/

  class << self
    def client
      @@client
    end

    def get_file(content, type)
      content.find do |file|
        type === file['path']
      end
    end

    def file_path(file)
      if file.present?
        client.media(file['path'])['url']
      end
    end

    def diff_restaurants_file(content = nil)
      content = available_files unless content.present?

      file_path get_file(content, DIFF_RESTAURANTS_REGEX)
    end

    def diff_places_file(content = nil)
      content = available_files unless content.present?

      file_path get_file(content, DIFF_PLACES_REGEX)
    end

    def instagram_file(content = nil)
      content = available_files unless content.present?

      file_path get_file(content, INSTAGRAM_REGEX)
    end

    def restaurants_file(content = nil)
      content = available_files unless content.present?

      file_path get_file(content, RESTAURANTS_REGEX)
    end

    def places_file(content = nil)
      content = available_files unless content.present?

      file_path get_file(content, PLACES_REGEX)
    end

    def available_files
      client.metadata(FOLDER)['contents']
    end

    def delta_instagram(content)
      content = available_files unless content.present?

      instagram = get_file(content, INSTAGRAM_REGEX)
      if today?(instagram['modified'])
        url = file_path(instagram)
        Instagram::Importer.import_from_url(url)
      end
    end

    def delta_venues(content)
      content = available_files unless content.present?

      places = get_file(content, DIFF_PLACES_REGEX)
      if today?(places['modified'])
        url = file_path(places)
        Factual::DiffImporter.import_from_url(url)
      end
    end

    def delta_restaurants(content)
      content = available_files unless content.present?

      places = get_file(content, DIFF_RESTAURANTS_REGEX)
      if today?(places['modified'])
        url = file_path(places)
        Factual::DiffImporter.import_from_url(url)
      end
    end

    def today?(date_string)
      date_string.present? && DateTime.parse(date_string) > 1.day.ago
    end

    def webhook_update(delta, options = {})
      content = available_files

      delta_instagram(content)
      delta_venues(content)
      delta_restaurants(content)
    end
  end
end