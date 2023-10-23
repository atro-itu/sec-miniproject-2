require "optparse"
require "socket"
require "./ssl_helpers"

class Client
  include SSLHelpers

  ORDER = 47
  PORTS = [4747, 4748, 4749]
  HOSPITAL = 5000

  def initialize(id, verbose)
    @id = id
    @verbose = verbose

    share1, share2 = rand(ORDER + 1), rand(ORDER + 1)
    share3 = ORDER - (share1 + share2)
    @shares = [share1, share2, share3]

    @received = []

    log "Initialized with shares #{@shares}"
  end

  def run
    log "Starting IO loop"
    while (line = $stdin.gets.chop)
      if line == "send"
        send_shares
      elsif line == "receive"
        receive_shares
      elsif line == "hospital"
        send_to_hospital
      elsif line == "print"
        puts self
      else
        puts "Invalid command. Valid commands are 'send', 'receive', 'print'"
      end
    end
  end

  def receive_shares
    with_ssl_context do |ctx|
      tcp_server = TCPServer.new(PORTS[@id])
      server = OpenSSL::SSL::SSLServer.new(tcp_server, ctx)

      log "Opening server to receive shares"

      client = server.accept
      msg = client.gets.to_i

      log "Received #{msg}"

      @received << msg

      client.close
      log "Finished receiving!"

      server.close
      log "Closed server!"
    end
  end

  def send_shares
    log "Sending shares"
    p1, p2 = (@id + 1) % 3, (@id + 2) % 3

    establish_tls_connection(PORTS[p1]) do |sock|
      log "Sending shares to #{p1}"
      sock.puts(@shares[p1])
    end

    establish_tls_connection(PORTS[p2]) do |sock|
      log "Sending shares to #{p2}"
      sock.puts(@shares[p2])
    end

    log "Finished sending!"
  end

  def send_to_hospital
    log "Sending shares to hospital"

    establish_tls_connection(HOSPITAL) do |sock|
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
    @shares[@id] + @received.sum
  end
end

verbose = false
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb [OPTIONS] id"
  opts.on("-v", "--verbose", "Run verbosely") do |v|
    verbose = v
  end
end.parse!

Client.new(ARGV[0].to_i, verbose).tap do |client|
  client.run
end
