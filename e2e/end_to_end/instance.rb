require 'pathname'

module EndToEnd
  class Instance
    DEFAULT_OPTIONS = {
      config: 'config.yml',
      environment: ENV['RAILS_ENV'] || 'development',
      browser: 'firefox',
      load_app: false,
      pr: nil,
      pry: false
    }

    attr_reader :options

    def initialize(options = DEFAULT_OPTIONS)
      @options = DEFAULT_OPTIONS.merge(options)
      load_app if options[:load_app]
      load_pry if options[:pry]
    end

    def app_loaded?
      options[:load_app]
    end

    def browser
      @browser ||= Browser.new(options[:browser])
    end

    def config
      @config ||= Config.new_from_file(config_path)
    end

    def config_path
      config = options[:config]
      # Note this will fail for non Unixy paths
      if config[0] == '/'
        Pathname.new(config)
      else
        EndToEnd.root.join(config)
      end
    end

    def environment
      options[:environment]
    end

    def pull_request
      options[:pr] if environment == 'staging'
    end

    def load_app
      ENV['RAILS_ENV'] ||= environment
      require File.expand_path('../../../config/environment', __FILE__)
    end

    def load_pry
      require 'pry'
      require 'pry-rescue/minitest'
      require 'pry-stack_explorer'
    end
  end
end
