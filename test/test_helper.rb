# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'database_cleaner'
require 'test_declarative'
require 'mocha/setup'
require 'webmock'

begin
  require 'rails-controller-testing'
  Rails::Controller::Testing.install
rescue LoadError
end

WebMock.enable!

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Helper for adding sample .yml file to load path
def load_sample_yml(fname)
  I18n.load_path << "#{File.dirname(__FILE__)}/support/#{fname}"
end

ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)

## do not enforce available locales
I18n.config.enforce_available_locales = false

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :transaction

DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  include WebMock::API

  if respond_to?(:use_transactional_tests=)
    self.use_transactional_tests = true
  else
    self.use_transactional_fixtures = true
  end
  setup do
    clear_redis
    Lit.init.cache.reset
  end
  teardown do
    WebMock.reset!
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Stop ActiveRecord from wrapping tests in transactions
  if respond_to?(:use_transactional_tests=)
    self.use_transactional_tests = false
  else
    self.use_transactional_fixtures = false
  end

  setup do
    DatabaseCleaner.strategy = :truncation
    I18n.backend.reload!
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
    DatabaseCleaner.strategy = :transaction
  end
end

class ActionController::TestCase
  include Warden::Test::Helpers
  if defined?(Devise::Test::ControllerHelpers)
    include Devise::Test::ControllerHelpers
  else
    include Devise::TestHelpers
  end
  Warden.test_mode!

  # Disable keyword arguments deprecation notice for now
  def non_kwarg_request_warning
    nil
  end
end
