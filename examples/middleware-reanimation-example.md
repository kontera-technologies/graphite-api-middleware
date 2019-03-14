## Environment
* Graphite server running on `graphite-server:2003`
* GraphiteAPI-Middleware running on `graphite-middleware-node:2005`

## Starting GraphiteAPI-Middlware
```bash
workspace $ graphite-api-middleware --help
Graphite API Middleware Server
Usage:
  graphite-api-middleware <graphite-uri>...
              [-d | --daemonize]
              [-p=<port> | --port=<port>]
              [-l=<log-file> | --log-file=<log-file>]
              [-L=<log-level> | --log-level=<log-leve>]
              [-P=<pid-file> | --pid-file=<pid-file>]

              [-i=<interval> | --interval=<interval>]
              [-s=<slice> | --slice=<slice>]
              [-r=<reanimation> | --reanimation=<reanimation>]
              [-m=<aggregation-method> | --aggregation-method=<aggregation-method>]
  graphite-api-middleware -v | --version
  graphite-api-middleware -h | --help

Arguments:
  <graphite-uri> List of URIs (seperated by spaces) that point to graphite API servers [udp,tcp]://host:port

Options:
  -h, --help                                                         Show this screen.
  -v, --version                                                      Show version.
  -d, --daemonize                                                    Run as a daemon.
  -p=<port>, --port=<port>                                           Listening port for this server.
  -l=<log-file>, --log-file=<log-file>                               Listening port for this server.
  -L=<log-level>, --log-level=<log-level>                            Log level (defaults to warn).
  -P=<pid-file>, --pid-file=<pid-file>                               Path to the PID to use (defaults to /var/run/graphite-api-middleware.pid).
  -i=<interval>, --interval=<interval>                               The interval to wait between each report (defaults to 60).
  -s=<slice>, --slice=<slice>                                        This middleware will send reports to graphite in slices of X seconds (defaults to 60).
  -r=<reanimation>, --reanimation=<reanimation>                      Reanimate records that are younger than X hours, please see README.
  -m=<aggregation-method>, --aggregation-method=<aggregation-method> The aggregation method (sum, avg or replace) for multiple reports in the same time slice (defaults to s
um).

More Info @ https://github.com/kontera-technologies/graphite-api-middleware

workspace $ graphite-api-middleware graphite-server:2003
            --port 2005 \
						--interval 5 \
						--log-level debug \
						--log-file /tmp/graphite-api-middleware.out \
						--daemonize \
						--reanimation 2
```

## Client
Sending the same record `example.value1 10 1335101880` twice in ten minutes interval

```bash
workspace $ telnet localhost 2005
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
example.value1 10 1335101880
example.value1 10 1335101880 # AFTER 10 MINUTES
^C
workspace $
```

## Flow
```ruby
workspace $ cat /tmp/graphite-api-middleware.out
 INFO -- : Server running on port 2005
 DEBUG -- : [:middleware, :connecting, "localhost:65364"]
 DEBUG -- : [:middleware, :message, "localhost:65364", "example.value1 10 1335101880\r\n"]
 DEBUG -- : [:buffer, :add, {:metric=>{"example.value1"=>"10"}, :time=>2012-04-22 06:38:00 -0700}]
 DEBUG -- : [:connector_group, :publish, 1, [GraphiteAPI::Connector graphite-server:2003]]
 DEBUG -- : [:connector, :puts, "graphite-server:2003", "example.value1 10.0 1335101880"]
 DEBUG -- : [:middleware, :message, "localhost:65364", "example.value1 10 1335101880\r\n"]
 DEBUG -- : [:buffer, :add, {:metric=>{"example.value1"=>"10"}, :time=>2012-04-22 06:38:00 -0700}]
 DEBUG -- : [:connector_group, :publish, 1, [GraphiteAPI::Connector graphite-server:2003]]
 DEBUG -- : [:connector, :puts, "graphite-server:2003", "example.value1 20.0 1335101880"] # <= Resend with value of 20 (10 + 10)
```

## Same flow w/o reanimation
```ruby
 INFO -- : Server running on port 2005
 DEBUG -- : [:middleware, :connecting, "localhost:65364"]
 DEBUG -- : [:middleware, :message, "localhost:65364", "example.value1 10 1335101880\r\n"]
 DEBUG -- : [:buffer, :add, {:metric=>{"example.value1"=>"10"}, :time=>2012-04-22 06:38:00 -0700}]
 DEBUG -- : [:connector_group, :publish, 1, [GraphiteAPI::Connector graphite-server:2003]]
 DEBUG -- : [:connector, :puts, "graphite-server:2003", "example.value1 10.0 1335101880"]
 DEBUG -- : [:middleware, :message, "localhost:65364", "example.value1 10 1335101880\r\n"]
 DEBUG -- : [:buffer, :add, {:metric=>{"example.value1"=>"10"}, :time=>2012-04-22 06:38:00 -0700}]
 DEBUG -- : [:connector_group, :publish, 1, [GraphiteAPI::Connector graphite-server:2003]]
 DEBUG -- : [:connector, :puts, "graphite-server:2003", "example.value1 10.0 1335101880"] # <= Resend with value of 10
```
