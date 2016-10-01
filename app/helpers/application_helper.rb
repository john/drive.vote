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

end
