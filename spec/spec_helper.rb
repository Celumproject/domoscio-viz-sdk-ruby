require_relative '../lib/domoscio_viz'
require_relative './lib/domoscio_viz/shared_resources'

require 'capybara/rspec'
require 'capybara-webkit'
require 'fileutils'
require 'pp'
require 'active_support/all'

Capybara.default_driver = :webkit

def reset_domoscio_viz_configuration
  DomoscioViz.configure do |c|
    c.client_id = 14
    c.client_passphrase = '748add958564718f6d7add299655f95c'#
    c.temp_dir = File.expand_path('../tmp', __FILE__)
    FileUtils.mkdir_p(c.temp_dir) unless File.directory?(c.temp_dir)
  end
end
reset_domoscio_viz_configuration
