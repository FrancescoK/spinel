# SSLServer: a TCPServer whose accept answers an SSLSocket. Each case is a
# server thread and a client on loopback; the client trusts the Han River
# Test CA and checks the server's name.
require "openssl"
require "socket"

# The certificate for turn.jayang-dong.example and its key, and the CA that
# issued it: the ones openssl_server_accept.rb uses.
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
CA_PEM = <<~PEM
-----BEGIN CERTIFICATE-----
MIIBjzCCATWgAwIBAgIUI9ic9bX/0AmUyUWTCXiglCPfR0UwCgYIKoZIzj0EAwIw
HDEaMBgGA1UEAwwRSGFuIFJpdmVyIFRlc3QgQ0EwIBcNMjYxMDE3MTMxNTUzWhgP
MjEyNjA5MjMxMzE1NTNaMBwxGjAYBgNVBAMMEUhhbiBSaXZlciBUZXN0IENBMFkw
EwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEE4L0e4gJjpuc16X4tfwznrmlc4D+z3vQ
fGOiB2cJwwEhNaWDNk95IGW5n5WF64ObqEYcFpokFyWur1o4maXi1KNTMFEwHQYD
VR0OBBYEFKO6NMRxipdePH6frAL8zA4vlUrRMB8GA1UdIwQYMBaAFKO6NMRxipde
PH6frAL8zA4vlUrRMA8GA1UdEwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDSAAwRQIg
XYulJlIdEJaj58GW085QwX6x3q2emzlns3++66sg1bsCIQCx71OOJjZW1fB6A8vh
c9tqElaq1Z6KVZ3MlZ1IgrVQpQ==
-----END CERTIFICATE-----
PEM

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(OpenSSL::X509::Certificate.new(LEAF_PEM), OpenSSL::PKey.read(KEY_PEM))
STORE = OpenSSL::X509::Store.new
STORE.add_cert(OpenSSL::X509::Certificate.new(CA_PEM))

# A client that verifies the server, sends a place and prints the answer.
def visit(port, place)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
  ctx.verify_hostname = true
  ctx.cert_store = STORE
  sock = TCPSocket.new("127.0.0.1", port)
  ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
  ssl.hostname = "turn.jayang-dong.example"
  ssl.connect
  ssl.write("#{place}\n")
  p ssl.gets
  ssl.close
  sock.close
end

server = OpenSSL::SSL::SSLServer.new(TCPServer.new("127.0.0.1", 0), ctx)
p server.to_io.class
p server.start_immediately
p server.listen(16)
port = server.addr[1]

# accept answers an SSLSocket whose handshake is done, and which takes the
# accepted socket with it when it closes.
t = Thread.new do
  ssl = server.accept
  line = ssl.gets
  ssl.write("Han River: #{line}")
  ssl.close
  [ssl.class, ssl.sync_close, ssl.to_io.closed?]
end
visit(port, "Jayang-dong")
p t.value

# A client that does not speak TLS: the handshake fails inside accept, which
# raises, and the accepted socket is closed with it, so the client reads to
# the end instead of waiting.
t = Thread.new do
  begin
    server.accept
    "accepted"
  rescue OpenSSL::SSL::SSLError
    "SSLError"
  end
end
plain = TCPSocket.new("127.0.0.1", port)
plain.write("GET /")
p t.value
begin
  plain.read
  p "closed"
rescue SystemCallError
  p "closed"
end
plain.close

# With start_immediately false, accept answers before any handshake, and
# the server bounds it: a client that connects and sends nothing is given
# up after 0.2 s, and closing the SSLSocket closes its socket.
server.start_immediately = false
quiet = TCPSocket.new("127.0.0.1", port)
ssl = server.accept
p ssl.accept_nonblock(exception: false)
p IO.select([ssl.to_io], nil, nil, 0.2)
ssl.close
p ssl.to_io.closed?
quiet.close

# ... and a client that does send its hello is handshaken the same way.
t = Thread.new do
  ssl = server.accept
  loop do
    r = ssl.accept_nonblock(exception: false)
    break if r == ssl
    r == :wait_readable ? IO.select([ssl.to_io], nil, nil, 5) : IO.select(nil, [ssl.to_io], nil, 5)
  end
  ssl.write("Han River: #{ssl.gets}")
  ssl.close
  "accepted"
end
visit(port, "Incheon")
p t.value

server.close
p server.closed?
