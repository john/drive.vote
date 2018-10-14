# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'devise'
require 'support/controller_macros.rb'
require 'vcr'
require 'uri'
require 'openssl'
require 'json'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Constants related to Gmaps API calls, and useful below in comparing URIs for
# VCR record/playback.
QUERY_PARAM_NAME_GMAPS_API_KEY = "key"
QUERY_PARAM_NAME_GMAPS_API_KEY_REPLACEMENT_VALUE = "REDACTED"

# Tag constant or Gmaps-related VCR callbacks.
VCR_TAG_GMAPS = :gmaps

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb

  # Returns a String object which represents a stable hash of the given URI
  # ignoring the optional excluded_keys (Array<String>).
  hash_for_uri = proc do |request_uri, exclude_keys|
    exclude_keys ||= []
    request_uri = URI.parse(request_uri.to_s) # clone since we may mutate
    q = URI.decode_www_form(request_uri.query).
      reject { |pair| exclude_keys.include?(pair[0]) }.
      sort { |pairA, pairB| pairA[0].<=>(pairB[0]) }
    request_uri.query = URI.encode_www_form(q)
    OpenSSL::Digest::MD5.digest(request_uri.to_s).unpack("H*")
  end

  # Returns a String which represents the given URI with all values matching a
  # key in replacements (Hash<String, String>) replaced as specified.
  uri_with_replaced_keys = proc do |request_uri, replacements|
    replacements ||= {}
    request_uri = URI.parse(request_uri.to_s) # clone since we may mutate
    q = URI.decode_www_form(request_uri.query).inject([]) do |a, pair|
      param, value = pair[0], pair[1]
      if replacements.key?(param)
        value = replacements[param]
      end
      a << [param, value]
    end
    request_uri.query = URI.encode_www_form(q)
    request_uri.to_s
  end

  # The following config invocations determine how we handle Gmaps API calls
  # during tests. By default, we use a single cassette to serve all requests.
  # Any that are not available will be recorded, using live requests to the
  # Gmaps APIs authenticated using the key in the environment variable
  # GOOGLE_API_KEY.
  #
  # By default this key is not specified during test runs, which means tests
  # which introduce previously unseen API calls will fail (for lack of a
  # configured API key). To rebuild the playback cache, remove the cached
  # cassette and regenerate it by running the test suite with a valid Gmaps API
  # key (as of this writing, 10/13/2018, the key only needs to invoke the
  # Geocoding API). From docker, this might be with an invocation like:
  #
  # $ rm spec/fixtures/vcr_cassettes/gmaps.yml
  #
  # $ docker-compose exec web bundle exec rake spec GOOGLE_API_KEY=YOUR_ACTUAL_KEY
  config.before_record(VCR_TAG_GMAPS) do |interaction|
    is_likely_gmaps_api_key_error = proc do
      JSON.parse(interaction.response.body)["status"] == "REQUEST_DENIED"
    end
    if interaction.response.status.code != 200 || is_likely_gmaps_api_key_error.()
      # Don't bother recording requests that aren't re-usable
      interaction.ignore!
    end
    interaction.request.uri = uri_with_replaced_keys.(interaction.request.uri, {
      QUERY_PARAM_NAME_GMAPS_API_KEY => QUERY_PARAM_NAME_GMAPS_API_KEY_REPLACEMENT_VALUE,
    })
  end

  config.around_http_request(lambda { |req| req.uri =~ /maps\.googleapis\.com/ }) do |request|
    opts = {
      tags: [VCR_TAG_GMAPS],
      record: :new_episodes,
      match_requests_on: [
        :method,
        proc do |req1, req2|
          hash_for_uri.(req1.uri, [QUERY_PARAM_NAME_GMAPS_API_KEY]) ==
            hash_for_uri.(req2.uri, [QUERY_PARAM_NAME_GMAPS_API_KEY])
        end,
      ],
    }
    VCR.use_cassette("gmaps", opts, &request)
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.extend ControllerMacros, :type => :controller

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # note we cannot rely on VCR for http calls to timezone b/c it adds a timestamp
  # to every call
  config.before :each do
    allow(Timezone).to receive(:lookup).and_return(nil)
  end
end
