require "socket"
require "optparse"
require "./ssl_helpers"

class Hospital
  include SSLHelpers

  CLIENT_PORTS = [4747, 4748, 4749]
  PORT = 5000

  def initialize(verbose)
    @shares = []
    @verbose = verbose
    @cert_path = "hospital.cert"
    @key_path = "hospital.key"
  end

  def run
    puts "Started hospital. Waiting for connections..."
    with_ssl_context do |ctx|
      tcp_server = TCPServer.new(PORT)
      server = OpenSSL::SSL::SSLServer.new(tcp_server, ctx)
      log "Opening server to receive shares"
      3.times do
        client = server.accept
        msg = client.gets.to_i
        log "Received #{msg}"
        @shares << msg
        client.close
        log "Finished receiving!"
        log "Received shares: #{@shares}"
      end
      server.close
      log "Closed server!"
    end
    puts "Received shares: #{@shares}"
    puts "Sum: #{@shares.sum}"
  end

  private

  def log(msg)
    puts "Hospital: #{msg}" if @verbose
  end
end

verbose = false
OptionParser.new do |opts|
  opts.banner = "Usage: hospital.rb [OPTIONS]"
  opts.on("-v", "--verbose", "Run verbosely") do |v|
    verbose = v
  end
end.parse!

Hospital.new(verbose).run
