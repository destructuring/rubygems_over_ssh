require 'net/ssh/gateway'
require 'uri'

module RubyGemsOverSSH
  class << self
    def open_tunnel(gateway, remote_port)
      begin
        try_port = 1025 + rand(60_000)
        gateway.open("localhost", remote_port, try_port)
        return try_port
      rescue Errno::EADDRINUSE
        retry
      end
    end

    def init_tunnel(host, port)
      local_port = nil
      port ||= 80
      key = host + ":" + port.to_s
      @tunnels ||= {}
      @tunnels[key] ||= begin
        gateway = Net::SSH::Gateway.new(host, nil)
        local_port = open_tunnel(gateway, port)
        puts "rubygemsoverssh: opened tunnel to #{key} (listening locally on #{local_port})"
        {:gateway => gateway, :local_port => local_port}
      end
      @tunnels[key][:local_port]
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

begin
  require 'rubygems/commands/inabox_command'
rescue LoadError
end

if Gem::Commands.const_defined?(:InaboxCommand)
  class Gem::Commands::InaboxCommand < Gem::Command
    alias_method :geminabox_host_without_tunnel, :geminabox_host

    def geminabox_host
      host = geminabox_host_without_tunnel
      uri = URI.parse(host)
      if uri.scheme == "ssh+http"
        local_port = RubyGemsOverSSH.init_tunnel(uri.host, uri.port)
        host = "http://localhost:#{local_port}/"
      end
      host
    end
  end
end
