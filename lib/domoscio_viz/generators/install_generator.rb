require 'rails/generators'

module DomoscioViz
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc "Generate config file for DomoscioViz configuration"

    def install
        copy_file "install.rb", "config/initializers/domoscio_viz.rb"
    end
  end
end