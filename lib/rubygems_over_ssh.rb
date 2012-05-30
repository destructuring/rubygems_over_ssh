require 'net/ssh/gateway'

module RubyGemsOverSSH
  class << self
    def init_tunnel(host, port)
      @tunnels ||= {}
      @tunnels["#{host}:#{port}"] ||= begin
        puts "rubygemsoverssh: opening tunnel to #{host}:#{port}"
        gateway = Net::SSH::Gateway.new(host, `whoami`.chomp)
        gateway.open("localhost", port, 9080)
      end
      9080
    end
  end
end

if Object.const_defined?(:Bundler)
  module Bundler
    module Source
      class Rubygems
        alias :specs_without_ssh :specs

        def specs(*args, &block)
          preserve_remotes = @remotes
          @remotes = @remotes.map { |r|
            if r.scheme == "ssh+http"
              local_port = RubyGemsOverSSH.init_tunnel(r.host, r.port)
              URI.parse("http://localhost:#{local_port}/")
            else
              r
            end
          }
          specs_without_ssh(*args, &block)
        ensure
          @remotes = preserve_remotes
        end
      end
    end
  end
end
