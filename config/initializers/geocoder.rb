# config/initializers/geocoder.rb

GEO_NEARBY_DISTANCE = 75

Geocoder.configure(

  # geocoding service (see below for supported options):
  :lookup => :google,

  # IP address geocoding service (see below for supported options):
  # :ip_lookup => :maxmind,

  # to use an API key:
  :api_key => ENV['GOOGLE_API_KEY'],

  # geocoding service request timeout, in seconds (default 3):
  :timeout => 10,

  # set default units to kilometers:
  :units => :km

  # caching (see below for details):
  # :cache => Redis.new,
  # :cache_prefix => "dtv_geo"

)