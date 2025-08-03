ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "fakeredis"


module ActiveSupport
  class TestCase
    include Devise::Test::IntegrationHelpers
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class AppRedisClient
  include Singleton

  def initialize
    @redis = Redis.new # Esto será un FakeRedis::Redis si se ha cargado
  end

  def redis
    @redis
  end
end
