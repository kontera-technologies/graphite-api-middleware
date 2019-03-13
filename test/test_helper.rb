$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'simplecov'
require 'simplecov-rcov'
require 'codecov'
require "minitest/autorun"

SimpleCov.start { add_filter "/tests/" }
SimpleCov.formatter = Class.new do
  def format(result)
     SimpleCov::Formatter::Codecov.new.format(result) if ENV["CODECOV_TOKEN"]
     SimpleCov::Formatter::RcovFormatter.new.format(result) unless ENV["CI"]
  end
end

require "graphite-api-middleware"

module GraphiteApiMiddleware::Tests
  class TestCase < Minitest::Test
  end

  module Utils
    def self.random_non_repeating_port
      @ports ||= (1000..9999).to_a.shuffle
      @ports.pop
    end

    def self.stop_em_if_running
      EM.stop if EM.reactor_running?
      sleep 0.1 while EM.reactor_running?
    end
  end

  module MockServer
    def initialize db
      @db = db
    end
    def receive_data data
      @db.push data
    end
  end
end
