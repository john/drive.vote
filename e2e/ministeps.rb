#
# Ministeps
#

# Feature
#

# Wraps a `describe` block so that it adds helper methods such as an accessor
# to a global configuration merge with any provided configs
def Feature(message, config: {}, &block)
  describe_class = describe(message, &block)
  conf = config # Prevent recursive calls
  describe_class.class_eval do
    define_method :browser do
      EndToEnd.browser
    end
    define_method :config do
      @config ||= OpenStruct.new(EndToEnd.config.to_h.merge(conf))
    end
  end
  describe_class
end

# Scenario
#

# Alias for Minitest's `it`
def Scenario(*args, &block)
  it(*args, &block)
end

# Step block
#

# Appends the provided message to the Minitest::Assertion error on failure
def step(message, skip: false, app: false, &block)
  if app && EndToEnd.app_loaded? || !app
    if block_given? && !skip
      block.call
      puts "#{message}"
    else
      puts "Skipping #{message}"
    end
  end
rescue Minitest::Assertion => assertion
  msg = %Q[Failure in "#{message}": #{assertion.message}]
  assertion.define_singleton_method(:message) { msg }
   raise assertion
rescue => error
  msg = %Q[Error in "#{message}": #{error.message}]
  error.define_singleton_method(:message) { msg }
  raise error
end

# Step aliases
alias :Check :step
alias :First :step
alias :Given :step
alias :Step :step
alias :Then :step

