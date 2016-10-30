# Run these tests with TEST_REQUIRES to test loading pry and the Rails app
$LOAD_PATH.unshift File.expand_path("../", __FILE__)

require "minitest/autorun"
require "end_to_end"
require "end_to_end/support"

file_pattern = File.expand_path("../end_to_end_test/**/test_*.rb", __FILE__)
Dir.glob(file_pattern).each { |f| require f }
