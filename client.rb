require "optparse"
require "socket"
require "./ssl_helpers"

class Client
  include SSLHelpers

  PORTS = [4747, 4748, 4749]
  HOSPITAL = 5000

  def initialize(id, verbose)
    @secret = rand(100..200)
    @id = id
    @verbose = verbose
    @cert_path = "client_#{id}.cert"
    @key_path = "client_#{id}.key"

    share1, share2 = rand(@secret + 1), rand(@secret + 1)
    @share3 = @secret - (share1 + share2)
    @shares = [share1, share2]

    @received = []

    puts "Client: #{@id}: Initialized with shares [#{@shares.join(", ")}, #{@share3}]. Secret is #{@secret}"
  end

  def run
    PORTS.each do |port|
      (port == PORTS[@id]) ? send_shares(port) : receive_shares(port)
    end

    log "My received is: #{@received}"
    log "My sum is: #{output}"
    log "Sending to hospital..."

    send_to_hospital

    log "Finished!"
  end

  def receive_shares(port)
    establish_tls_connection_with_retries(port, 5) do |sock|
      log "Receiving share from client at port #{port}"
      @received << sock.gets.to_i
      log "Finished receiving shares: #{@received}"
    end
  end

  def send_shares(port)
    with_ssl_context do |ctx|
      tcp_server = TCPServer.new(port)
      server = OpenSSL::SSL::SSLServer.new(tcp_server, ctx)
      2.times do |i|
        server.accept.tap do |client|
          log "Broadcasting share #{@shares.last}"
          client.puts @shares.pop
          client.close
        end
      end

      log "Finished sending shares"
    end
  end

  def send_to_hospital
    log "Sending shares to hospital"

    establish_tls_connection_with_retries(HOSPITAL, 5) do |sock|
      sock.puts(output)
    end

    log "Finished sending to hospital!"
  end

  def to_s
    "Id: #{@id}, Shares: #{@shares}, Received: #{@received}"
  end

  private

  def log(msg)
    puts "Client #{@id}: #{msg}" if @verbose
  end

  def output
    @share3 + @received.sum
  end
end

verbose = false
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb [OPTIONS] id"
  opts.on("-v", "--verbose", "Run verbosely") do |v|
    verbose = v
  end
end.parse!

Client.new(ARGV[0].to_i, verbose).run
