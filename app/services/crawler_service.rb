class CrawlerService

  def self.fetch_meta_property(short_url)
    begin
      doc = Nokogiri::HTML(open(short_url))
      doc.at('meta[property="og:image"]').attributes['content'].value
    rescue Errno::ENOENT => e
      data = {
        name: 'CrawlerService',
        data: {short_url: short_url},
        error: e.message
      }

      Failure.create(data)
      return nil
    end
  end

end