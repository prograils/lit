class RemoteInteractorService
  def initialize(source)
    @source = source
  end

  def send_request(path, query_values = {})
    uri = initialize_uri(path, query_values)
    req = initialize_request(uri)
    connection = initialize_connection(uri)
    perform_request(connection, req)
  rescue => e
    return unless defined?(Rails)
    ::Rails.logger.error { "Lit remote error: #{e}" }
  end

  private

  def initialize_uri(path, query_values)
    uri = URI(@source.url + path)
    query_values.each do |k, v|
      params = URI.decode_www_form(uri.query || '') << [k, v]
      uri.query = URI.encode_www_form(params)
    end
    uri
  end

  def initialize_request(uri)
    req = Net::HTTP::Get.new(uri.request_uri)
    req.add_field('Authorization', %(Token token="#{@source.api_key}"))
    req
  end

  def initialize_connection(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.port == 443)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def perform_request(connection, request)
    res = connection.start { |http| http.request(request) }
    return res unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end
end
