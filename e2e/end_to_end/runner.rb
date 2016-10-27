require 'optparse'

module EndToEnd
  class Runner
    attr_reader :arguments, :options, :feature_files

    # arguments - String array of command-line arguments (ARGV)
    def initialize(arguments = [])
      @arguments = arguments
      @options = {}
    end

    def parse!
      option_parser.parse!(arguments)
      options.merge(options)
      # TODO: Cleanup. This is very hacky.
      @feature_files = arguments.map do |file|
        if file[0] == '/'
          file
        elsif file[0, 7] == 'end_to_end'
          EndToEnd.root.join(file).to_s.gsub('/end_to_end/end_to_end',  '/end_to_end')
        else
          EndToEnd.root.join(file).to_s
        end
      end
      @feature_files = EndToEnd.all_feature_files if @feature_files.empty?
      self
    end

    def set_end_to_end_instance
      EndToEnd.instance = Instance.new(options)
    end

    def run
      set_end_to_end_instance
      feature_files.each { |f| require f }
    end

    private

    def option_parser
      @option_parser ||= OptionParser.new do |parser|
        parser.banner = "Usage: end_to_end/run [options] [files or directories]\n\n"

        parser.on('-b', '--browser STRING', "Specify the browser to run: chrome, firefox, ios, safari, phantomjs(headless)") do |browser|
          options[:browser] = browser
        end

        parser.on('-c', '--config STRING', "Specify the path of a config file to use") do |config|
          options[:config] = config
        end

        parser.on('-e', '--env STRING', "Specify the Rails environment to test against") do |environment|
          options[:environment] = environment
        end

        parser.on('--pry', "Load pry and enable drop in debugging on") do
          options[:pry] = true
        end
      end
    end
  end
end
