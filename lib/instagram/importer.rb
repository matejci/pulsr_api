require "smarter_csv"
require 'fileutils'

class Instagram::Importer
  BATCH_SIZE = 200_000

  DIRECTORY = Rails.root + "tmp/instagram/import/"

  class << self
    def import_from_url url
      FactualDownloader.download(url, 'import_instagram_places') do |filename|
        import_from_file(filename)
      end
    end

    def import_from_file filename
      start_time = Time.current

      pool = create_pool

      options = {
        col_sep: "\t",
        quote_char: "\x00",
        chunk_size: 200
      }

      is_header = true
      counter = 0
      file_index = 1

      file = open_file(file_index)

      SmarterCSV.process(filename, options) do |chunk|
        chunk.each do |item|
          counter += 1

          file << extract_places(item) if item[:namespace_id].present?
        end
      end
      file.close

      Instagram::Place.new(file_index).process
      remove_file(file_index)

      log "[#{DateTime.now}] Finished processing in #{Time.now - start_time}s."
    end

    def create_pool
      pool_options = {
        min_threads: 2,
        max_threads: 3,
        max_queue: 0 # unbounded work queue
      }

      Concurrent::ThreadPoolExecutor.new pool_options
    end

    def add_to_pool pool, index
      pool.post do
        Instagram::Place.new(index).process
        remove_file(index)
      end
    end


    def upload_csv_to_places(index, join = false)
      thread = Thread.new do
        Instagram::Place.new(index).process
        remove_file(index)
      end

      thread.join if join
    end

    def open_file(index, attributes = "wb")
      options = {
        col_sep: ";"
      }
      file_name = csv_file_name(index)

      log "[#{DateTime.now}] Opened new Instagram file import #{file_name}"

      csv = CSV.open(file_name, attributes, options)
      csv << Instagram::Place.csv_headers
      csv
    end

    def log content
      Rails.logger.info content
    end

    def csv_file_name(index)
      FileUtils.mkdir_p(self::DIRECTORY) unless File.exists?(self::DIRECTORY)
      self::DIRECTORY + "import-#{index}.csv"
    end

    def remove_file(index)
      file = csv_file_name(index)
      File.delete(file) if File.exist?(file)
    end

    def extract_places(place)
      columns = Instagram::Place::FILE_COLUMNS

      columns.values.map {|element| place[element] }
    end

  end
end