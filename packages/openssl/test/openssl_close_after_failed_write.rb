# SSLSocket#close after a write the peer was no longer there to take. CRuby's
# close drops the flush error and closes (`flush rescue nil`), so a client
# that rescued the failed write can still close in an ensure.
require "openssl"
require "socket"

# The certificate for turn.jayang-dong.example and its key: the ones
# openssl_server_accept.rb uses.
LEAF_PEM = <<~PEM
-----BEGIN CERTIFICATE-----
MIIBdDCCARmgAwIBAgICFOUwCgYIKoZIzj0EAwIwHDEaMBgGA1UEAwwRSGFuIFJp
dmVyIFRlc3QgQ0EwIBcNMjYxMDE3MTMxNTUzWhgPMjEyNjA5MjMxMzE1NTNaMCMx
ITAfBgNVBAMMGHR1cm4uamF5YW5nLWRvbmcuZXhhbXBsZTBZMBMGByqGSM49AgEG
CCqGSM49AwEHA0IABLd+fb/6Dh7v0j8wTq9i9pMngYdBanyRG+Gx0hNVWGPdXG6v
lmzEDNShpSzBykTn2fdUaBUldnyOAWzdNprHF2CjQjBAMB0GA1UdDgQWBBRSzkcf
82FjWxf5FScoX08DsF8reTAfBgNVHSMEGDAWgBSjujTEcYqXXjx+n6wC/MwOL5VK
0TAKBggqhkjOPQQDAgNJADBGAiEA9iM/A6HVmXKQL7XDGgjN7f2wiWkZ6calAR65
i16rYbcCIQDjR0XO8BgjrG6mI7C5NevMDdYCuW4qRPD35tzRvssOYw==
-----END CERTIFICATE-----
PEM
KEY_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIPIRlQfBz7+HavOzW8H69dntBcUZ0MicF3/FxGctM0W1oAoGCCqGSM49
AwEHoUQDQgAEt359v/oOHu/SPzBOr2L2kyeBh0FqfJEb4bHSE1VYY91cbq+WbMQM
1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END EC PRIVATE KEY-----
PEM

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(OpenSSL::X509::Certificate.new(LEAF_PEM), OpenSSL::PKey.read(KEY_PEM))

# The server finishes the handshake and drops the TCP connection without a
# close_notify.
server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
t = Thread.new do
  sock = server.accept
  ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
  ssl.accept
  sock.close
  "dropped"
end

client_ctx = OpenSSL::SSL::SSLContext.new
client_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
sock = TCPSocket.new("127.0.0.1", port)
ssl = OpenSSL::SSL::SSLSocket.new(sock, client_ctx)
ssl.connect
p t.value

# The read sees the connection gone (CRuby raises on the missing
# close_notify, and Spinel answers nil); then writes go on until one fails,
# which leaves its bytes unwritten in the buffer close flushes.
begin
  ssl.gets
rescue OpenSSL::SSL::SSLError
end
failed = false
100.times do
  begin
    ssl.write("Seoul to Gimpo\n")
  rescue OpenSSL::SSL::SSLError, SystemCallError
    failed = true
  end
  break if failed
  sleep 0.01
end
p failed
p ssl.close
sock.close
server.close
