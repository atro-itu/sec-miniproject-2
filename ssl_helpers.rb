require "openssl"

module SSLHelpers
  def establish_tls_connection(port, &block)
    with_ssl_context do |ctx|
      tcp_sock = TCPSocket.open("localhost", port)
      OpenSSL::SSL::SSLSocket.new(tcp_sock, ctx).tap do |sock|
        sock.connect
        yield sock
        sock.close
      end
    end
  end

  def with_ssl_context(&block)
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.cert = OpenSSL::X509::Certificate.new(File.open("server.cert"))
    ctx.key = OpenSSL::PKey::RSA.new(File.open("server.key"))
    ctx.min_version = :TLS1_3
    yield ctx
  end
end
