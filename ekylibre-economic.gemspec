$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ekylibre-economic/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ekylibre-economic"
  s.version     = EkylibreEconomic::VERSION
  s.authors     = ["Ekylibre"]
  s.email       = ["dev@ekylibre.com"]
  s.summary     = "Economic plugin for Ekylibre"
  s.description = "Economic plugin for Ekylibre"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc", "Capfile"]
  s.require_path = ['lib']

  s.add_dependency 'activesupport', '>= 5.2'
  s.add_dependency 'rails', '>= 5.2'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rails', '>= 5.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rest-client'
end
