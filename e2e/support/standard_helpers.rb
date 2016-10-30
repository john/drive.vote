require 'uri'

module StandardHelpers
  def b
    EndToEnd.browser
  end

  def visit(url)
    if url.start_with?('http')
      browser.goto(url)
    elsif url.start_with?('/')
      browser.goto("#{base_url}#{url}")
    else
      browser.goto("#{base_url}/#{url}")
    end
  end

  def base_url
    uri = URI(current_url)
    url = "#{uri.scheme}://#{uri.host}"
    url << ":#{uri.port}" unless uri.port == 80
    url
  end

  def current_url
    browser.url
  end

  def current_path
    URI(current_url).path
  end
end
