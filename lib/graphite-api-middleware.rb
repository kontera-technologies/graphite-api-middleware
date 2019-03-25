# -----------------------------------------------------
# Graphite Middleware Server
# Should be placed between graphite server and graphite clients
# - Data Aggregator
# - Caching
# - Data Manipulation
# -----------------------------------------------------
# Usage:
#   GraphiteApiMiddleware::Server.start(options)
#
# Options:
#   graphite         target graphite hostname
#   reanimation_exp  cache lifetime in seconds  (default is 43200 seconds)
#   prefix           add prefix to each key
#   interval         report to graphite every X seconds (default is 60)
#   slice            send to graphite in X seconds slices (default is 60)
#   log_level        info
# -----------------------------------------------------
require "graphite-api-middleware/version"
require 'graphite-api'
require 'eventmachine'
require 'socket'
require 'logger'

module GraphiteApiMiddleware
  class Server < EventMachine::Connection

    def initialize client, logger
      @client = client
      @logger = logger
    end

    attr_reader :client, :client_id

    def post_init
      @client_id = peername
      @logger.debug [:middleware, :connecting, client_id]
    end

    def receive_data data
      @logger.debug [:middleware, :message, client_id, data]
      client.stream data, client_id
    end

    def unbind
      @logger.debug [:middleware, :disconnecting, client_id]
      client.cancel
    end

    def peername
      port, *ip = get_peername[2,6].unpack "nC4"
      [ip.join("."),port].join ":"
    end

    private :peername

    def self.default_options
      GraphiteAPI::Client.default_options.
        tap {|opts| opts.delete :backends}.
        merge interval: 60, pid: '/var/run/graphite-api-middleware.pid'
    end

    def self.start options, logger
      EventMachine.run do
        GraphiteAPI::Logger.logger = logger
        logger.info "Server running on port #{options[:port]}"

        client = GraphiteAPI::Client.new options

        # Starting server
        [:start_server, :open_datagram_socket].each do |method_name|
          EventMachine.send(method_name, '0.0.0.0', options[:port], self, client, logger)
        end
      end
    end

    def self.stop
      EventMachine.stop
    end

  end
end
