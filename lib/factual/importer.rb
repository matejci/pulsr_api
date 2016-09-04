class Factual::Importer < Factual::BaseImporter
  DIRECTORY = Rails.root + "tmp/factual/import/"

  class << self
    def import_from_url url
      FactualDownloader.download(url, 'factual_venues_import') do |filename|
        import_from_file(filename)
      end
    end

    def diff_import?
      false
    end

    def headers_column
      Factual::Venue.csv_headers
    end

    def extract_venue(venue)
      columns = Factual::Venue::FILE_COLUMNS
      values = []
      time_now = Time.current

      columns.each do |name, elements|
        values << if elements.is_a? Array
          elements.map {|el| venue[el] }.join(' ').strip
        else
          item = venue[elements]

          case elements
          when columns[:country]
            item = 'United States' if item == 'us'
          when columns[:hours]
            if venue[columns[:hours]] == "REMOVE"
              item = "{}"
            end
          when columns[:created_at]
            item = time_now
          when columns[:updated_at]
            item = time_now
          when columns[:short_factual_id]
            short_id = venue[columns[:factual_id]]
            item = short_id.split('-').first
          end

          item
        end
      end

      values
    end
  end
end