require 'net/http'

class GooglePlaces
  # these are for now individual's api keys that increase the free limit but
  # do not result in any billing
  API_KEYS = ENV['GOOGLE_PLACES_KEYS'].to_s.split(',').map(&:strip)
  GOOGLE_URL = 'https://maps.googleapis.com/maps/api/place/textsearch/json'

  # returns the google results from a places text query or nil on error
  # this is an array of hashes with relevant keys:
  #   'name' - for places, full name like 'Cragmont Elementary School'
  #   'types' - array of types like "street_address", "church"
  #   'formatted_address' - full address with state, zip, United States
  #   'geometry' - hash {"location"=>{"lat"=>37.91784809999999, "lng"=>-122.2827213}
  def self.search query
    uri = URI(GOOGLE_URL)
    uri.query = URI.encode_www_form(query: query, key: API_KEYS[rand(API_KEYS.length)])
    begin
      JSON.parse(Net::HTTP.get(uri))['results']
    rescue
      nil
    end
  end
end