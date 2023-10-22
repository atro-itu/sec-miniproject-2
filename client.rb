require 'socket'
require 'openssl'

host = 'localhost'
port = 8080

socket = TCPSocket.open(host,port)
ctx = OpenSSL::SSL::SSLContext.new()

# ctx.key = OpenSSL::PKey::RSA.new 2048
# ctx.cert = OpenSSL::X509::Certificate.new
# ctx.cert.subject = OpenSSL::X509::Name.new [['CN', 'localhost']]
# ctx.cert.issuer = ctx.cert.subject
# ctx.cert.public_key = ctx.key
# ctx.cert.not_before = Time.now
# ctx.cert.not_after = Time.now + 60 * 60 * 24
# ctx.cert.sign ctx.key, OpenSSL::Digest::SHA1.new

ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ctx)
ssl_socket.sync_close = true
ssl_socket.connect

ssl_socket.puts("hello world")
ssl_socket.close
