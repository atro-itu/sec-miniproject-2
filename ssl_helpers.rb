require "openssl"

module SSLHelpers
  def establish_tls_connection_with_retries(port, max_retries, &block)
    with_ssl_context do |ctx|
      retries = 0
      finished = false
      while retries < max_retries && !finished
        begin
          tcp_sock = TCPSocket.open("localhost", port)
          OpenSSL::SSL::SSLSocket.new(tcp_sock, ctx).tap do |sock|
            sock.connect
            yield sock
            sock.close
            finished = true
          end
        rescue Errno::ECONNREFUSED
          log "Waiting for #{port} to come online... Attempt: #{retries + 1}"
          sleep 1
          retries += 1
        end
      end
    end
  end

  def with_ssl_context(&block)
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.cert = OpenSSL::X509::Certificate.new(File.open("certs/#{@cert_path}"))
    ctx.key = OpenSSL::PKey::RSA.new(File.open("certs/#{@key_path}"))
    ctx.min_version = :TLS1_3
    yield ctx
  end
end
