require 'net/ssh/gateway'

module RubyGemsOverSSH
  class << self
    def init_tunnel(host)
      @tunnels ||= {}
      @tunnels[host] ||= begin
        gateway = Net::SSH::Gateway.new(host, `whoami`.chomp)
        gateway.open("localhost", 80, 9080)
      end
      9080
    end
  end
end

if Object.const_defined?(:Bundler)
  module Bundler
    module Source
      class Rubygems
        def add_remote(source)
          if source =~ %r{^gem\+ssh://(.*)}
            puts "opening tunnel to #{$1}"
            port = RubyGemsOverSSH.init_tunnel($1)
            source = "http://localhost:#{port}"
          end

          puts source
          @remotes << normalize_uri(source)
        end
      end
    end
  end
end
