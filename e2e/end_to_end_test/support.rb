# Simple Mock
class Watir::Browser
  attr_reader :browser
  def initialize(browser)
    @browser = browser
  end
end
