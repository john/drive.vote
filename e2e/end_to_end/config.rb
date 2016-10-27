require 'ostruct'
require 'yaml'

module EndToEnd
  class Config < OpenStruct
    def self.get_config_for_env(env, config_hash)
      env_hash = config_hash[env]  || {}
      set_config_url_for_staging(env_hash)
      config_hash.merge(env_hash)
    end
    def self.new_from_file(file)
      config_hash = YAML.load_file(file)
      new_from_hash(config_hash)
    end
    def self.new_from_yaml(yaml)
      config_hash = YAML.load(yaml)
      new_from_hash(config_hash)
    end

    def self.new_from_hash(hash)
      new(get_config_for_env(EndToEnd.environment, hash))
    end

    def self.set_config_url_for_staging(env_hash)
      if EndToEnd.environment == 'staging' && !EndToEnd.pull_request.nil?
        env_hash['url'] = env_hash['pr_url'] % { pr: EndToEnd.pull_request }
      end
    end
  end

  def append(options)
    options.each { |key, value| add_member(key, value) }
  end

  def add_member(key, value)
    new_ostruct_member(key) unless respond_to?("#{key}=")
    self.send("#{key}=", value)
  end
end
