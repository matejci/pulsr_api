Geocoder.configure(
  timeout: 5,                       # geocoding service timeout (secs)
  lookup: :google,                  # name of geocoding service (symbol)
  language: :en,                    # ISO-639 language code
  # use_https: false,               # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,                # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,               # HTTPS proxy server (user:pass@host:port)

  # prefix (string) to use for all cache keys
  cache_prefix: 'geocoder:',

  # Calculation options
  units: :km                        # :km for kilometers or :mi for miles
  # distances: :linear              # :spherical or :linear
)

Geocoder.config[:cache] = Redis.new(:url => ENV['REDIS_GEOCODER_CACHE_PATH'])
