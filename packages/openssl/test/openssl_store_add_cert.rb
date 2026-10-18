# X509::Store#add_cert: a client that trusts the Han River Test CA, and no
# other, connects to a server presenting a certificate that CA issued. The
# client checks the chain and the name, so this is a verified handshake on
# loopback, with no trust store from the operating system in it.
require "openssl"
require "socket"

# The certificate for turn.jayang-dong.example, the P-256 key behind it and
# the CA that issued it: the ones openssl_server_accept.rb uses.
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

leaf = OpenSSL::X509::Certificate.new(LEAF_PEM)
ca = OpenSSL::X509::Certificate.new(CA_PEM)
server_ctx = OpenSSL::SSL::SSLContext.new
server_ctx.add_certificate(leaf, OpenSSL::PKey.read(KEY_PEM))

# One connection: the server sends the leaf alone, so the client can build
# the chain only from what its store holds. A refused handshake can reach
# the server as the client's alert or as the reset of its close, so either
# reads as refused there.
def exchange(server_ctx, store, hostname)
  server = TCPServer.new("127.0.0.1", 0)
  port = server.addr[1]
  t = Thread.new do
    sock = server.accept
    ssl = OpenSSL::SSL::SSLSocket.new(sock, server_ctx)
    begin
      ssl.accept
      line = ssl.gets
      ssl.write("Han River: #{line}")
      ssl.close
      "accepted"
    rescue OpenSSL::SSL::SSLError, SystemCallError
      "server: refused"
    ensure
      sock.close
    end
  end

  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
  ctx.verify_hostname = true
  ctx.cert_store = store
  sock = TCPSocket.new("127.0.0.1", port)
  ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
  ssl.hostname = hostname
  begin
    ssl.connect
    ssl.write("Incheon\n")
    p ssl.gets
    ssl.close
  rescue OpenSSL::SSL::SSLError => e
    p "client: #{e.class}"
  end
  sock.close
  p t.value
  server.close
end

store = OpenSSL::X509::Store.new
p store.class
p store.add_cert(ca).equal?(store)
exchange(server_ctx, store, "turn.jayang-dong.example")

# The same certificate under another name: the chain holds, the name does
# not.
exchange(server_ctx, store, "gimpo.example")

# A store without the CA: nothing the client trusts issued the certificate.
exchange(server_ctx, OpenSSL::X509::Store.new, "turn.jayang-dong.example")
