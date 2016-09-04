class Eventful::Importer::Core
  class << self
    def import
      new.import
    end
  end

  def object
    "event" # "performer", "venue", "event"
  end

  def period
    "daily" # "daily", "weekly"
  end

  def action
    "full" # "updates", "full", "withdrawn"
  end

  def process
    puts "Override to process"
  end

  def process_type
    "_#{action}_#{period}_#{object}s"
  end

  def weekly?
    period == "weekly"
  end

  def timestamp
    (weekly? ? Date.today.monday : Date.today).strftime "%Y%m%d"
  end

  def import
    download_file
    process
    cleanup_file
  end

  def log content
    Rails.logger.info content
  end

  def download_file
    cleanup_file
    log "Download URL #{url}"
    `curl -o #{download_file_name} #{url} && gunzip #{download_file_name}`
  end

  def cleanup_file
    if File.exists? file_to_process
      log "Remove file: #{download_file_name}"
      FileUtils.rm(file_to_process)
    end
  end

  def directory
    Rails.root + 'tmp/eventful/importer'
  end

  def root_url
    "http://static.eventful.com/images/export/"
  end

  def url
    "#{root_url}pulsr-#{timestamp}-#{action}-#{object}s.xml.gz"
  end

  def file_name
    "import#{process_type}"
  end

  def download_file_name
    FileUtils.mkdir_p(directory) unless File.exists?(directory)
    directory + "#{file_name}.xml.gz"
  end

  def file_to_process
    FileUtils.mkdir_p(directory) unless File.exists?(directory)
    directory + "#{file_name}.xml"
  end

end