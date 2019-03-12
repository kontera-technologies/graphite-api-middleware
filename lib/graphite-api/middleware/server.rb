# -----------------------------------------------------
# Graphite Middleware Server
# Should be placed between graphite server and graphite clients
# - Data Aggregator
# - Caching
# - Data Manipulation
# -----------------------------------------------------
# Usage:
#   GraphiteAPI::Middleware::Server.start(options)
#
# Options:
#   graphite         target graphite hostname
#   reanimation_exp  cache lifetime in seconds  (default is 43200 seconds)
#   prefix           add prefix to each key
#   interval         report to graphite every X seconds (default is 60)
#   slice            send to graphite in X seconds slices (default is 60)
#   log_level        info
# -----------------------------------------------------
require 'graphite-api'
require 'eventmachine'
require 'socket'

module GraphiteAPI::Middleware
  class Server < EventMachine::Connection

    def initialize buffer
      @buffer = buffer and super
    end

    attr_reader :buffer, :client_id

    def post_init
      @client_id = peername
      GraphiteAPI::Logger.debug [:middleware, :connecting, client_id]
    end

    def receive_data data
      GraphiteAPI::Logger.debug [:middleware, :message, client_id, data]
      buffer.stream data, client_id
    end

    def unbind
      GraphiteAPI::Logger.debug [:middleware, :disconnecting, client_id]
    end

    def peername
      port, *ip = get_peername[2,6].unpack "nC4"
      [ip.join("."),port].join ":"
    end

    private :peername

    def self.start options
      EventMachine.run do
        GraphiteAPI::Logger.info "Server running on port #{options[:port]}"

        buffer = GraphiteAPI::Buffer.new options
        group  = GraphiteAPI::Connector::Group.new options

        # Starting server
        [:start_server, :open_datagram_socket].each do |m|
          EventMachine.send(m,'0.0.0.0',options[:port],self,buffer)
        end

        # Send metrics to graphite every X seconds
        Zscheduler.every(options[:interval], :on_shutdown => true) do
          group.publish buffer.pull :string if buffer.new_records?
        end

      end
    end

  end
end
