# Note: These tests are pretty lame because it's annoying to initialize
# Selenium::WebDriver instances
class TestEndToEndBrowser < Minitest::Test
  def test_inheritance
    assert EndToEnd::Browser.ancestors.include?(Watir::Browser)
  end

  def test_initialize
    assert_equal 'firefox', EndToEnd::Browser.new('firefox').browser
  end

  def test_initialize_ios
    assert_raises(Errno::ECONNREFUSED) { EndToEnd::Browser.new('ios') }
  end
end
