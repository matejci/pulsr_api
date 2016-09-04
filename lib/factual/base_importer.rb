require "smarter_csv"
require 'fileutils'

class Factual::BaseImporter
  BATCH_SIZE = 200_000

  DIRECTORY = Rails.root + "tmp/factual/import/"

  class << self
    def import_from_url url
      FactualDownloader.download(url, 'base-import') do |filename|
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

          file << extract_venue(item)
        end
      end
      file.close

      Factual::Venue.new(file_index, diff_import?).process
      remove_file(file_index)

      Rails.logger.info "[#{DateTime.now}] Finished processing in #{Time.now - start_time}s."
    end

    def create_pool
      pool_options = {
        min_threads: 1,
        max_threads: 2,
        max_queue: 0 # unbounded work queue
      }

      Concurrent::ThreadPoolExecutor.new pool_options
    end

    def add_to_pool pool, index
      pool.post do
        Factual::Venue.new(index, diff_import?).process
        remove_file(index)
      end
    end

    def process_data(index_list)
      Parallel.each(index_list) {|file_index| upload_csv_to_venues(file_index) }
    end

    def upload_csv_to_venues(index, join = false)
      thread = Thread.new do
        Factual::Venue.new(index, diff_import?).process
        remove_file(index)
      end

      thread.join if join
    end

    def open_file(index, attributes = "wb")
      options = {
        col_sep: ";"
      }
      file_name = csv_file_name(index)

      Rails.logger.info "[#{DateTime.now}] Opened new Factual file import #{file_name}"

      csv = CSV.open(file_name, attributes, options)
      csv << headers_column
      csv
    end


    def csv_file_name(index)
      FileUtils.mkdir_p(self::DIRECTORY) unless File.exists?(self::DIRECTORY)
      self::DIRECTORY + "import-#{index}.csv"
    end

    def remove_file(index)
      file = csv_file_name(index)
      File.delete(file) if File.exist?(file)
    end
  end
end