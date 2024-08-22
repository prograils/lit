# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# We get a whole bunch of method redefinition warnings, mostly coming
# from Devise - e.g. when routes are reloaded in controller tests.
# That's not ideal but we don't need those. (Funny enough, default `$VERBOSE`
# when using `rails test` instead of `rake` is `false`)
$VERBOSE = false # equivalent to `ruby -W1`

require File.expand_path("dummy/config/environment.rb", __dir__)
require "rails/test_help"
require "capybara/rails"
require "database_cleaner"
require "test_declarative"
require "minitest/autorun"
require "mocha/minitest"
require "vcr"
require "minitest-vcr"
require "webmock"

begin
  require "rails-controller-testing"
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

ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)

## do not enforce available locales
I18n.config.enforce_available_locales = false

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  include WebMock::API

  if respond_to?(:use_transactional_tests=)
    self.use_transactional_tests = false
  else
    self.use_transactional_fixtures = true
  end
  setup do
    clear_redis
    DatabaseCleaner.start
    Lit.init.cache.reset
  end
  teardown do
    DatabaseCleaner.clean
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
    DatabaseCleaner.strategy = :truncation
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

  # Using the new request format, convert to old request format if needed
  # @example
  #   call_action :get, :show, params: { ... }
  def call_action(verb, action, params: {})
    send verb, action, params:
  end
end

VCR.configure do |config|
  # config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "test/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end

MinitestVcr::Spec.configure!

def assert_no_database_queries
  ActiveRecord::Base.connection.stubs(:execute)
    .raises(Minitest::Assertion, "The block should not make any database calls")
  yield
  ActiveRecord::Base.connection.unstub(:execute)
end
