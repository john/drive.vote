module UrlHelpers
  def root_url
    config.url
  end

  PATHS = {
    sign_in: '/sign_in',
    volunteer_to_drive: '/volunteer_to_drive'
  }

  PATHS.each do |base_name, path|
    define_method "#{base_name}_path" do
      path
    end
    define_method "#{base_name}_url" do
      "#{root_url}#{path}"
    end
  end
end
