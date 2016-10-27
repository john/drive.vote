require 'pathname'
require 'end_to_end/browser'
require 'end_to_end/config'
require 'end_to_end/instance'
require 'end_to_end/runner'

module EndToEnd
  class << self
    attr_accessor :instance

    def instance
      @instance ||= Instance.new
    end

    # Delegate everything to the singleton instance
    def method_missing(method, *args, &block)
      instance.send(method, *args, &block)
    end

    def all_feature_files
      Dir[EndToEnd.root.join("features/**/*.rb")]
    end

    def root
      @root ||= Pathname.new(File.expand_path('../', __FILE__))
    end
  end
end

