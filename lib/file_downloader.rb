class FileDownloader
  class << self
    def client
      @http ||= HTTPClient.new
    end

    def photo_from_url(url)
      if head(url).code == 200
        URI.parse(url).open
      else
        nil
      end
    end

    def get(url, follow_redirect = true)
      client.get(url, follow_redirect: follow_redirect)
    end

    def head(url, follow_redirect = true)
      client.get(url, follow_redirect: follow_redirect)
    end

    def get_content(url, follow_redirect = true)
      client.get_content(url, follow_redirect: follow_redirect)
    end
  end
end