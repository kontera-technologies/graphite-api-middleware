require "test_helper"

class Graphite::Api::MiddlewareTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Graphite::Api::Middleware::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
