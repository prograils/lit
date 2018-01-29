$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'lit/version'

Gem::Specification.new do |s|
  s.name        = 'lit'
  s.version     = Lit::VERSION
  s.authors     = ['Maciej Litwiniuk', 'Piotr Boniecki', 'Michał Buszkiewicz']
  s.email       = ['maciej@litwiniuk.net']
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/prograils/lit'
  s.summary     = 'Database powered i18n backend with web gui'
  s.description = "Translate your apps with pleasure (sort of...) and for free.
                   It's simple i18n web interface, build on top of twitter
                   bootstrap, that one may find helpful in translating app by
                   non-technicals. "

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile',
                                               'README.md']
  s.add_dependency 'i18n', '~> 0.7'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'rails', '>= 4.2.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'devise'
  s.add_development_dependency 'pg'
end
