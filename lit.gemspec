$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lit"
  s.version     = Lit::VERSION
  s.authors     = ["Maciej Litwiniuk"]
  s.email       = ["maciej@litwiniuk.net"]
  s.license     = 'MIT'
  s.homepage    = "https://github.com/prograils/lit"
  s.summary     = "Database powered i18n backend with web gui"
  s.description = "Translate your apps with pleasure (sort of...) and for free. It's simple i18n web interface, build on top of twitter bootstrap, that one may find helpful in translating app by non-technicals. "

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  #s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "> 3.1.0"
  s.add_dependency "jquery-rails"
  s.add_dependency 'sass-rails', '> 3.1'
  s.add_dependency 'bootstrap-sass'

  s.add_development_dependency "pg"
  s.add_development_dependency "devise"
  s.add_development_dependency "fakeweb", ["~> 1.3"]
  #s.add_test_dependency "capybara"
end
