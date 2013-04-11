# stdlib modules
require 'net/http'
require 'webrick'
require 'webrick/https'
require 'webrick/httpproxy'

require 'vcr'

require 'vcr_proxy/server'
require 'vcr_proxy/constants'
require 'vcr_proxy/dependency'

require 'vcr_proxy/railtie' if VCRProxy::Dependency.rails3?

module VCRProxy
  include Constants

  class << self
    def start(opts = {})
      server = Server.new(opts)
      server.start
      server
    end

    def start_with_pid
      raise ArgumentError.new('rails 3 is needed') unless Dependency.rails3?

      path = Rails.root.join('tmp/pids/')
      path.mkdir unless path.directory?

      path = path.join('vcr_proxy_server.pid')

      opts = {
        :Port => ENV['VCR_PROXY_PORT'] || VCRProxy::DEFAULT_PORT
      }

      pid = Process.fork { VCRProxy.start(opts) }

      path.open('w') do |file|
        file.puts pid
      end
    end

    def stop_with_pid
      raise ArgumentError.new('rails 3 is needed') unless Dependency.rails3?

      path = Rails.root.join('tmp/pids/vcr_proxy_server.pid')

      if path.exist?
        pid = path.read.chomp

        `kill -s int #{pid}`
      else
        puts <<-MSG
=> Looked in tmp/pids/, but no VCRProxy pids found, so nothing happened.
MSG
      end
    end

    # FIXME how do we implement configuraion
    def configure(opts = {})
      VCR.configure do |c|
        c.hook_into :webmock
        c.cassette_library_dir = opts[:cassettes] ||= DEFAULT_CASSETTES
        c.default_cassette_options = { :record => :new_episodes }
        c.ignore_localhost = true
        c.ignore_hosts "127.0.0.1"
      end
    end
  end
end
