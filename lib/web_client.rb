class WebClient

  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.2 Safari/537.36'

  DOMAIN_REGEX = /^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)\//im
  DOMAIN_URL_REGEX = /^((?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)\/?)/im

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    Zlib::DataError
  ]

  class << self
    def page_content(uri_string, limit = 10)
      # You should choose better exception.
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      url = URI.parse(uri_string)

      http = Net::HTTP.new(url.host, url.port)
      if url.is_a? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = Net::HTTP::Get.new(url.path, {
        'User-Agent' => USER_AGENT
      })

      response = http.request(req)

      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then page_content(response['location'], limit - 1)
      else
        response.error!
      end
    end

    def domain_url uri_string
      url = uri_string.scan(DOMAIN_URL_REGEX).flatten.first
      url << "/" unless url.ends_with? "/"
      url
    end

    def twitter_username uri_string
      puts "#{uri_string} Loading... "
      body = page_content uri_string

      TwitterClient.instance.extract_username(body)
    rescue *HTTP_ERRORS => e
      begin
        puts "Root Domain Loading... "
        puts "#{domain_url(uri_string)} Loading... "
        body = page_content domain_url(uri_string)

        TwitterClient.instance.extract_username(body)
      rescue *HTTP_ERRORS => e
        nil
      end
    rescue StandardError => error
      nil
    end
  end
end