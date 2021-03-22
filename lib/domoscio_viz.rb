
require 'net/https'
require 'cgi/util'
require 'multi_json'
# helpers
require 'domoscio_viz/version'
require 'domoscio_viz/json'
require 'domoscio_viz/errors'
require 'domoscio_viz/authorization_token'
# generators
require 'domoscio_viz/generators/install_generator'
# resources
require 'domoscio_viz/http_calls'
require 'domoscio_viz/resource'
require 'domoscio_viz/chart/chart'

module DomoscioViz

  class Configuration
    attr_accessor :root_url, :client_id, :client_passphrase, :temp_dir

    def root_url
      @root_url ||= ""
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  def self.api_uri(url='')
    URI(configuration.root_url + url)
  end

  #
  # - +method+: HTTP method; lowercase symbol, e.g. :get, :post etc.
  # - +url+: the part after Configuration#root_url
  # - +params+: hash; entity data for creation, update etc.; will dump it by JSON and assign to Net::HTTPRequest#body
  #
  # Performs HTTP requests to Adaptive Engine
  # On token issues, will try once to get a new token then will output a DomoscioViz::ReponseError with details
  #
  # Raises DomoscioViz::ResponseError on Adaptive Error Status
  # Raises DomoscioViz::ProcessingError on Internal Error
  #
  def self.request(method, url, params={})

    store_tokens, headers = request_headers
    params.merge!({'per_page': 2000}) unless params[:per_page]
    uri = api_uri(url)

    response = DomoscioViz.send_request(uri, method, params, headers)
    return response if response.kind_of? DomoscioViz::ProcessingError

    begin
      raise_http_failure(uri, response, params)
      data = DomoscioViz::JSON.load(response.body.nil? ? '' : response.body)
      DomoscioViz::AuthorizationToken::Manager.storage.store({access_token: response['Accesstoken'], refresh_token: response['Refreshtoken']}) if store_tokens
    rescue MultiJson::LoadError => exception
      data = ProcessingError.new(uri, 500, exception, response.body, params)
    rescue ResponseError => exception
      data = exception
    end

    data
  end

  private

  # This function catches usual Http errors during calls
  #
  def self.send_request(uri, method, params, headers)
    begin
      response = perform_call(uri, method, params, headers)
      response = retry_call_and_store_tokens(uri, method, params, headers) if ['401','403'].include? response.code
      response
    rescue Timeout::Error, Errno::EINVAL, HTTP::ConnectionError, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => exception
      ProcessingError.new(uri, 500, exception, response, params)
    end
  end

  # This helper will check the response status and build the correcponding DomoscioRails::ResponseError
  #
  def self.raise_http_failure(uri, response, params)
    unless response.kind_of? Net::HTTPSuccess
      if response.blank?
        raise ResponseError.new(uri, 500, {error: {status: 500, message: 'VisualizationEngine not available'}}, {}, params)
      else
        body = DomoscioViz::JSON.load((response.body.nil? ? '' : response.body), :symbolize_keys => true)
        raise ResponseError.new(uri, response.code.to_i, body, response.body, params)
      end
    end
  end

  # Actual HTTP call is performed here
  #
  def self.perform_call(uri, method, params, headers)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      req = Net::HTTP::const_get(method.capitalize).new(uri.request_uri, headers)
      req.body = DomoscioRails::JSON.dump(params)
      http.request req
    end
  end

  # This method is called when AdaptiveEngine returns tokens errors
  # Action on those errors is to retry and request new tokens, those new token are then stored
  def self.retry_call_and_store_tokens(uri, method, params, headers)
    headers = request_new_tokens
    response = perform_call(uri, method, params, headers)
    DomoscioViz::AuthorizationToken::Manager.storage.store({access_token: response['Accesstoken'], refresh_token: response['Refreshtoken']})
    response
  end

  def self.user_agent
    @uname ||= get_uname
    {
      bindings_version: DomoscioViz::VERSION,
      lang: 'ruby',
      lang_version: "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})",
      platform: RUBY_PLATFORM,
      uname: @uname
    }
  end

  def self.get_uname
    `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
  rescue Errno::ENOMEM
    'uname lookup failed'
  end

  # Process the token loading and analyze
  # will return the processed headers and a token store flag
  #
  def self.request_headers
    begin
      auth_token = DomoscioViz::AuthorizationToken::Manager.get_token
      if auth_token && auth_token[:access_token] && auth_token[:refresh_token]
        [false, send_current_tokens(auth_token)]
      else
        [true, request_new_tokens]
      end
    rescue SyntaxError, StandardError
      [true, request_new_tokens]
    end
  end

  # If stored token successfully loaded we build the header with them
  #
  def self.send_current_tokens(auth_token)
    {
      'user_agent' => "#{DomoscioViz.user_agent}",
      'ClientId' => "#{DomoscioViz.configuration.client_id}",
      'AccessToken' => "#{auth_token[:access_token]}",
      'RefreshToken' => "#{auth_token[:refresh_token]}",
      'Content-Type' => 'application/json'
    }
  end

  # If we cant find tokens of they are corrupted / expired, then we set headers to request new ones
  def self.request_new_tokens
    {
      'user_agent' => "#{DomoscioViz.user_agent}",
      'ClientId' => "#{DomoscioViz.configuration.client_id}",
      'Authorization' => "Token token=#{DomoscioViz.configuration.client_passphrase}",
      'Content-Type' => 'application/json'
    }
  end

  DomoscioViz.configure do |c|
      c.client_id = nil
      c.client_passphrase = nil
      c.temp_dir = File.expand_path('../tmp', __FILE__)
      FileUtils.mkdir_p(c.temp_dir) unless File.directory?(c.temp_dir)
  end
end