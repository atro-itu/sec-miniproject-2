require 'socket'
require 'openssl'

tcp_server = TCPServer.new 8080

ctx = OpenSSL::SSL::SSLContext.new
ctx.key = OpenSSL::PKey::RSA.new 2048
ctx.cert = OpenSSL::X509::Certificate.new
ctx.cert.subject = OpenSSL::X509::Name.new [['CN', 'localhost']]
ctx.cert.issuer = ctx.cert.subject
ctx.cert.public_key = ctx.key
ctx.cert.not_before = Time.now
ctx.cert.not_after = Time.now + 60 * 60 * 24
ctx.cert.sign ctx.key, OpenSSL::Digest::SHA1.new

ctx.verify_mode = OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

server = OpenSSL::SSL::SSLServer.new tcp_server, ctx
loop do
  Thread.start(server.accept) do |client|
    puts client.gets
    client.close
  end
end
