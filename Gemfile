source "http://rubygems.org"

# Declare your gem's dependencies in lit.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"
gem "haml", ">= 3.0.0"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

group :assets do
  gem 'coffee-rails', '>= 3.0.0'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'redis'
  gem 'simple_form'
  gem 'ransack'
  gem 'kaminari'
  gem "fakeweb", "~> 1.3", :require=>false
  gem "test_declarative", :require => false
  gem "mocha", :require => false
end

group :development, :test do
  gem 'devise'
  gem 'sqlite3'
end
