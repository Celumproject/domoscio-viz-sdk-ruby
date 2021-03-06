$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "domoscio_viz/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "domoscio_viz"
  s.version     = DomoscioViz::VERSION
  s.authors     = ["Benoit Praly"]
  s.email       = ["benoit.praly@domoscio.com"]
  s.homepage    = "http://www.domoscio.com"
  s.summary     = "Summary of DomoscioViz."
  s.description = "Ruby client to interact with Domoscio Viz Engine."
  s.license     = "MIT"

  # s.files = Dir["{lib,vendor}/**/*"]
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"
  # s.add_dependency 'active_support', '~> 3.0.0'
  #
  # s.add_development_dependency "sqlite3"
end
