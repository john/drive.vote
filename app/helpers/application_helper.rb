module ApplicationHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def tel_format(text)
    groups = text.to_s.scan(/(?:^\+)?\d+/)
    groups.join '-'
  end

  def tel_to(text)
    link_to text, "tel:#{tel_format(text)}"
  end

  def show_languages
    (request.fullpath.include?('admin') || request.fullpath.include?('dispatch')) ? false : true
  end

  # Modified from humane_flash_messages to escape HTML in message content.
  def escaped_humane_flash_messages
    content = ""
    unless flash[:notice].blank?
      content << javascript_tag("humane.notice(\"#{escape_javascript(html_escape flash[:notice])}\");")
    end
    unless flash[:error].blank?
      content << javascript_tag("humane.error(\"#{escape_javascript(html_escape flash[:error])}\");")
    end
    unless flash[:alert].blank?
      content << javascript_tag("humane.alert(\"#{escape_javascript(html_escape flash[:alert])}\");")
    end
    content
  end

end
