require 'watir'

module EndToEnd
  class Browser < Watir::Browser
    APPIUM_SERVER_URL = 'http://0.0.0.0:4723/wd/hub'

    def initialize(browser_name)
      driver =
        case browser_name
        when 'ios'
          ios_driver
        when 'phantomjs'
          phantomjs_driver
        else
          browser_name
        end
      super(driver)
    end

    private

    def ios_driver
      Selenium::WebDriver.for(:remote,
        url: APPIUM_SERVER_URL,
        desired_capabilities: {
          'platformName' => 'iOS',
          'platformVersion' => '10',
          'browserName' => 'Safari',
          'deviceName' => 'iPhone Simulator',
        })
    end

    def phantomjs_driver
      driver = Selenium::WebDriver.for(:phantomjs)
      # Needs to increase window size or certain tests outside of dimension
      # will fail
      driver.manage.window.size = Selenium::WebDriver::Dimension.new(1280, 1024)
      driver
    end
  end
end
