class FactualDownloader
  class << self

    def download url, file_name, &block
      downloader = new(file_name)

      downloader.remove_file
      downloader.download(url)
      if block.present?
        block.(downloader.file_to_process)
        downloader.remove_file
      end

      downloader.file_to_process
    end

    def remove file_name
      new(file_name).remove_file
    end
  end

  def initialize file_name
    @file_name = file_name
  end

  def download url
    `curl -o #{download_file_name} #{url} && gunzip #{download_file_name}`
  end

  def remove_file
    File.delete(download_file_name) if File.exist?(download_file_name)
    File.delete(file_to_process) if File.exist?(file_to_process)
  end

  def directory
    Rails.root + 'tmp/factual/downloader'
  end

  def download_file_name
    FileUtils.mkdir_p(directory) unless File.exists?(directory)
    directory + "#{@file_name}.tab.gz"
  end

  def file_to_process
    FileUtils.mkdir_p(directory) unless File.exists?(directory)
    directory + "#{@file_name}.tab"
  end


end