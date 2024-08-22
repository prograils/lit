$LOAD_PATH.push File.expand_path("lib", __dir__)

require "lit/version"

Gem::Specification.new do |s|
  s.name = "lit"
  s.version = Lit.version
  s.authors = ["Maciej Litwiniuk", "Piotr Boniecki", "Michał Buszkiewicz", "Szymon Soppa"]
  s.email = ["maciej@litwiniuk.net"]
  s.license = "MIT"
  s.homepage = "https://github.com/prograils/lit"
  s.summary = "Database powered i18n backend with web gui"
  s.description =
    "Translate your apps with pleasure (sort of...) and for free.
                   It's simple i18n web interface, build on top of twitter
                   bootstrap, that one may find helpful in translating app by
                   non-technicals. "

  s.files = Dir["{app,config,db,lib}/**/*"] + %w[MIT-LICENSE Rakefile README.md]
  s.add_dependency "emoji_flag"
  s.add_dependency "jquery-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "sassc"
  s.add_dependency "rails", ">= 7.0"

  s.add_development_dependency "appraisal", "~> 2.5.0"
  s.add_development_dependency "devise", "~> 4.8.0"
  s.add_development_dependency "minitest", "~> 5.20"
  s.add_development_dependency "pry-byebug", "~> 3.9"
  s.add_development_dependency "pry-stack_explorer", "~> 0.6.0"
  s.add_development_dependency "standard"
  s.add_development_dependency "standard-performance"
  s.add_development_dependency "standard-rails"
  s.add_development_dependency "vcr", "~> 6.0"
  s.add_development_dependency "webmock", "~> 3.4"
end
