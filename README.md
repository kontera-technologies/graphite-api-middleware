# Description
**GraphiteAPI Middleware** provides a way to interacting with **Graphite's Carbon Daemon**, by setting up the **GraphiteAPI-Middleware** daemon. This method implements Graphite's [plaintext protocol](http://graphite.readthedocs.org/en/1.0/feeding-carbon.html) for communication.

## Key Features
* **Multiple Graphite Servers Support** - GraphiteAPI-Middleware supports sending aggregated data to multiple graphite servers, in a multiplex fashion, useful for large data centers and backup purposes
* **Reanimation mode** - support cases which the same keys (same timestamps as well) can be received simultaneously and asynchronously from multiple input sources, in these cases GraphiteAPI-Middleware will "reanimate" old records (records that were already sent to Graphite server), and will send the sum of the reanimated record value + the value of the record that was just received to the graphite server; this new summed record should override the key with the new value on Graphite database.
* **non-blocking I/O** ( EventMachine aware ).
* **Thread-Safe** client.

## Status
[![Gem Version](https://badge.fury.io/rb/graphite-api-middleware.svg)](https://badge.fury.io/rb/graphite-api-middleware)
[![Build Status](https://travis-ci.org/kontera-technologies/graphite-api-middleware.svg?branch=master)](https://travis-ci.org/kontera-technologies/graphite-api-middleware)
[![Test Coverage](https://codecov.io/gh/kontera-technologies/graphite-api-middleware/branch/master/graph/badge.svg)](https://codecov.io/gh/kontera-technologies/graphite-api-middleware)

## Installation
Install stable version

```
gem install graphite-api-middleware
```

## Usage
* After installing this gem, the `graphite-api-middleware` command should be available.
  ```
  [root@graphite-middleware-node]# graphite-api-middleware --help

  GraphiteAPI Middleware Server

  Usage: graphite-api-middleware [options]
      -g, --graphite HOST:PORT         graphite host, in HOST:PORT format (can be specified multiple times)
      -p, --port PORT                  listening port (default 2003)
      -l, --log-file FILE              log file
      -L, --log-level LEVEL            log level (default warn)
      -P, --pid-file FILE              pid file (default /var/run/graphite-api-middleware.pid)
      -d, --daemonize                  run in background
      -i, --interval INT               report every X seconds (default 60)
      -s, --slice SECONDS              send to graphite in X seconds slices (default 60)
      -r, --reanimation HOURS          reanimate records that are younger than X hours, please see README
      -m, --aggregation-method method  The aggregation method (sum, avg or replace) for multiple reports in the same time slice (default sum)

  More Info @ https://github.com/kontera-technologies/graphite-api-middleware
  ```

* launch **GraphiteAPI-Middleware** daemon
  ```
  [root@graphite-middleware-node]# graphite-api-middleware          \
    --port 2005                                                     \
    --interval 60                                                   \
    --log-level debug                                               \
    --log-file /tmp/graphite-api-middleware.out                     \
    --daemonize                                                     \
    --graphite graphite-server:2003                                 \
    --graphite graphite-backup-server:2003
  ```

* Send metrics via **UDP/TCP sockets**
  ```
  [root@graphite-middleware-node] telnet localhost 2005
  Trying 127.0.0.1...
  Connected to localhost.
  Escape character is '^]'.
  example.middleware.value 10.2 1335008343
  example.middleware.value2 99 1334929231
  ^C
  [root@graphite-middleware-node]
  ```

## Example Setup
[![example setup](https://raw.github.com/kontera-technologies/graphite-api/master/examples/middleware_t1.png)]

## Development
After checking out the repo, run `bundle install` to install dependencies.
Before submitting a pull request, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

### Releasing a new version of this gem
1. Run `gem bump -v [major|minor|patch|alpha|beta|pre]` to bump the version number of this gem and create a new git commit for it.
2. Run `git push` to push the changes.
3. Run `gem tag` to create a git tag for this version.
4. Run `git push --tags` to push the tag to git.
5. Run `gem release` to build the gem and push it to rubygems.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/Eyal_Shalev/graphite-api-middleware. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

## Bugs
If you find a bug, feel free to report it @ our [issues tracker](https://github.com/kontera-technologies/graphite-api-middleware/issues) on github.

## License
It is free software, and may be redistributed under the terms specified in [LICENSE](/LICENSE.txt).

## Code of Conduct
Everyone interacting in the graphite-api-middleware project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the code of conduct.

## Warranty
This software is provided “as is” and without any express or implied warranties, including, without limitation, the implied warranties of merchantability and fitness for a particular purpose.
