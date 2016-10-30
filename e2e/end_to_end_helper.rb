$LOAD_PATH.unshift File.expand_path("../", __FILE__)
require "minitest/autorun"
require "end_to_end"
require "ministeps"

# Load support files
Dir[EndToEnd.root.join("support/**/*.rb")].each { |f| require f }

# Include global support files
include StandardHelpers
include UrlHelpers
include SignInHelpers
