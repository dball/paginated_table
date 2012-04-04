# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'minitest/autorun'
require 'capybara/rails'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

Capybara.javascript_driver = :webkit

class IntegrationTest < MiniTest::Spec
  include Capybara::DSL

  after do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

MiniTest::Spec.register_spec_type(/integration$/, IntegrationTest)
