# config/initializers/geocoder.rb

GEO_NEARBY_DISTANCE = 75

Geocoder.configure(

  # geocoding service (see below for supported options):
  :lookup => :google,
  # to use an API key:
  :api_key => ENV['GOOGLE_API_KEY'],
  
  # IP address geocoding service (see below for supported options):
  # :ip_lookup => :maxmind,

  # In most cases the implementation will imply this, but in cases, specifically
  # mocking or testing, being able to ensure that the underlying HTTP requests
  # are always via HTTPS is helpful in correctly selecting which mock requests
  # to use. In general, it's not likely that we'll be using a Geocoder which
  # makes live requests and which does not use SSL.
  use_https: true,

  # geocoding service request timeout, in seconds (default 3):
  :timeout => 10,

  # set default units to kilometers:
  :units => :km

  # caching (see below for details):
  # :cache => Redis.new,
  # :cache_prefix => "dtv_geo"

)
