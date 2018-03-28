
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
    attr_accessor :preproduction, :root_url,
    :client_id, :client_passphrase,
    :temp_dir

    def preproduction
      @preproduction || false
    end

    def root_url
      if @preproduction == true
        @root_url || "https://domoscio-viz-engine.herokuapp.com"
      else
        @root_url || "http://localhost:3002"
      end
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
  def self.request(method, url, params={}, filters={}, headers = request_headers, before_request_proc = nil)
    return false if @disabled
    uri = api_uri(url)
    uri.query = URI.encode_www_form(filters) unless filters.empty?

    res = DomoscioViz.send_request(uri, method, params, headers, before_request_proc)

    # decode json data
    begin
      data = DomoscioViz::JSON.load(res.body.nil? ? '' : res.body)
      DomoscioViz::AuthorizationToken::Manager.storage.store({client_id: res['ClientID'], client_passphrase: res['ClientPassphrase']})
    rescue MultiJson::LoadError
      data = {}
    end

    data
  end


  def self.send_request(uri, method, params, headers, before_request_proc)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http| # , use_ssl: uri.scheme == 'https') do |http|
      req = Net::HTTP::const_get(method.capitalize).new(uri.request_uri, headers)
      req.body = DomoscioViz::JSON.dump(params)
      before_request_proc.call(req) if before_request_proc
      http.request req
    end
  end

  private

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

  def self.request_headers
    headers = {
      'user_agent' => "DomoscioViz RubyBindings/#{DomoscioViz::VERSION}",
      'ClientID' => "#{DomoscioViz.configuration.client_id}",
      'ClientPassphrase' => "#{DomoscioViz.configuration.client_passphrase}",
      'Content-Type' => 'application/json'
    }
    headers
  end

  DomoscioViz.configure do |c|
      c.preproduction = false
      c.client_id = nil
      c.client_passphrase = nil
      c.temp_dir = File.expand_path('../tmp', __FILE__)
      FileUtils.mkdir_p(c.temp_dir) unless File.directory?(c.temp_dir)
  end

end
