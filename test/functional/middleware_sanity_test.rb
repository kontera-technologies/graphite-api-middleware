require "test_helper"
require 'eventmachine'
require 'socket'

module GraphiteApiMiddleware::Tests
  class MiddlewareSanityTest < TestCase
    EM_STOP_AFTER = 4
    MIDDLEWARE_STARTUP_WAIT = 1
    MIDDLEWARE_STOP_WAIT = 1
    MIDDLEWARE_BIN_FILE = File.expand_path("../../../bin/graphite-api-middleware", __FILE__)

    def setup
      @middleware_port = Utils.random_non_repeating_port
      @mock_server_port = Utils.random_non_repeating_port
      @data = []
      Utils.stop_em_if_running
    end

    def start_middleware middleware_port, servers, aggregation_method=nil, interval=2
      options = Array(servers)
      options += %W(--port #{middleware_port} --interval #{interval} -L error)
      options += ["--aggregation-method", aggregation_method] if aggregation_method
      @pid = Process.spawn("ruby", MIDDLEWARE_BIN_FILE, *options)
      sleep MIDDLEWARE_STARTUP_WAIT
    end

    def teardown
      Process.kill(:KILL, @pid)
      sleep MIDDLEWARE_STOP_WAIT
    end

    def test_with_defaults
      start_middleware @middleware_port, "tcp://localhost:#{@mock_server_port}"
      EventMachine.run {
        EventMachine.start_server("0.0.0.0", @mock_server_port, MockServer, @data)
        socket = TCPSocket.new("0.0.0.0", @middleware_port)
        1.upto(1000) do
          socket.puts("shuki.tuki1 1.1 123456789\n")
          socket.puts("shuki.tuki2 10 123456789\n")
          socket.puts("shuki.tuki3 10 123456789\n")
        end
        EventMachine::Timer.new(EM_STOP_AFTER, &EM.method(:stop))
      }

      expected = [
        "shuki.tuki1 1100.0 123456780",
        "shuki.tuki2 10000.0 123456780",
        "shuki.tuki3 10000.0 123456780"
      ]
      assert_expected_equals_data expected
    end

    def test_with_multiple_backends
      backend_ports = [@mock_server_port, Utils.random_non_repeating_port]
      start_middleware @middleware_port, backend_ports.map { |port| "tcp://localhost:#{port}" }
      data_sets = backend_ports.zip([[],[]])
      EventMachine.run {
        data_sets.map { |port, data| EventMachine.start_server("0.0.0.0", port, MockServer, data) }
        socket = TCPSocket.new("0.0.0.0", @middleware_port)
        1.upto(1000) do
          socket.puts("shuki.tuki1 1.1 123456789\n")
          socket.puts("shuki.tuki2 10 123456789\n")
          socket.puts("shuki.tuki3 10 123456789\n")
        end
        EventMachine::Timer.new(EM_STOP_AFTER, &EM.method(:stop))
      }
      expected = [
        "shuki.tuki1 1100.0 123456780",
        "shuki.tuki2 10000.0 123456780",
        "shuki.tuki3 10000.0 123456780"
      ]
      data_sets.each { |_,data| assert_expected_equals_data expected, data }
    end

    def test_with_avg
      start_middleware @middleware_port, "tcp://localhost:#{@mock_server_port}", 'avg'
      EventMachine.run {
        EventMachine.start_server("0.0.0.0", @mock_server_port, MockServer, @data)
        socket = TCPSocket.new("0.0.0.0", @middleware_port)
        1.upto(1000) do
          socket.puts("shuki.tuki1 1.0 123456789\n")
          socket.puts("shuki.tuki1 1.2 123456789\n")
        end
        EventMachine::Timer.new(EM_STOP_AFTER, &EM.method(:stop))
      }

      assert_expected_equals_data ["shuki.tuki1 1.1 123456780"]
    end

    def test_with_replace
      start_middleware @middleware_port, "tcp://localhost:#{@mock_server_port}", 'replace'
      EventMachine.run {
        EventMachine.start_server("0.0.0.0", @mock_server_port, MockServer, @data)
        socket = TCPSocket.new("0.0.0.0", @middleware_port)
        1.upto(1000) do
          socket.puts("shuki.tuki1 10.0 123456789\n")
          socket.puts("shuki.tuki1 5.0 123456789\n")
        end
        EventMachine::Timer.new(EM_STOP_AFTER, &EM.method(:stop))
      }

      assert_expected_equals_data ["shuki.tuki1 5.0 123456780"]
    end

    def assert_expected_equals_data expected, data=@data
      assert_equal expected, data.map {|o| o.split("\n")}.flatten(1).map(&:strip)
    end
  end
end
