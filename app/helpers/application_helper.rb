module ApplicationHelper

  def is_active(action)
    current_page?(:controller => action) ? 'active' : ''
  end

  def image_exists?(url)
    response = {}
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request # Net::HTTPResponse object
    end

    response.content_type.starts_with?("image")
  end

end
