# The server half of SSLSocket: a context given a certificate and its key,
# and #accept and #accept_nonblock on a socket TCPServer accepted. Each case
# is a whole handshake on loopback, a server thread and a client in this
# one, and a line each way over it. The client does not verify: what is
# checked is that the server can present a certificate and prove the key.
require "openssl"
require "socket"

# The certificate for turn.jayang-dong.example, issued by the Han River Test
# CA below, and the P-256 key behind it: the same pair
# openssl_x509_certificate.rb and openssl_pkey_read.rb use, made for these
# tests and valid until 2126.
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
# Its public half alone, which cannot sign a handshake.
PUBLIC_PEM = <<~PEM
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEt359v/oOHu/SPzBOr2L2kyeBh0Fq
fJEb4bHSE1VYY91cbq+WbMQM1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END PUBLIC KEY-----
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
# The CA's own key: a good key, and not the certificate's.
CA_KEY_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIHH2dZM16ldjbjxS25PBZbuMXfCpRcHwVionZAAKFIOfoAoGCCqGSM49
AwEHoUQDQgAEE4L0e4gJjpuc16X4tfwznrmlc4D+z3vQfGOiB2cJwwEhNaWDNk95
IGW5n5WF64ObqEYcFpokFyWur1o4maXi1A==
-----END EC PRIVATE KEY-----
PEM

leaf = OpenSSL::X509::Certificate.new(LEAF_PEM)
ca = OpenSSL::X509::Certificate.new(CA_PEM)
key = OpenSSL::PKey.read(KEY_PEM)

# One connection: the server thread accepts, blocking or not, reads a line
# and answers it; the client sends a place and reads the answer.
def exchange(ctx, nonblock)
  server = TCPServer.new("127.0.0.1", 0)
  port = server.addr[1]
  t = Thread.new do
    sock = server.accept
    ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
    begin
      if nonblock
        loop do
          r = ssl.accept_nonblock(exception: false)
          break if r == ssl
          if r == :wait_readable
            IO.select([sock])
          else
            IO.select(nil, [sock])
          end
        end
      else
        ssl.accept
      end
      line = ssl.gets
      ssl.write("Han River: #{line}")
      ssl.close
      "accepted"
    rescue OpenSSL::SSL::SSLError => e
      "server: #{e.class}"
    ensure
      sock.close
    end
  end

  client_ctx = OpenSSL::SSL::SSLContext.new
  client_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  sock = TCPSocket.new("127.0.0.1", port)
  ssl = OpenSSL::SSL::SSLSocket.new(sock, client_ctx)
  begin
    ssl.connect
    ssl.write("Jayang-dong\n")
    reply = ssl.gets
    version = ssl.ssl_version
    ssl.close
    p [version, reply]
  rescue OpenSSL::SSL::SSLError => e
    p "client: #{e.class}"
  end
  sock.close
  p t.value
  server.close
end

# A context holds nothing until it is given something, and add_certificate
# leaves the three readers as they were.
ctx = OpenSSL::SSL::SSLContext.new
p [ctx.cert.nil?, ctx.key.nil?, ctx.extra_chain_cert.nil?]
p ctx.add_certificate(leaf, key, [ca]).equal?(ctx)
p [ctx.cert.nil?, ctx.key.nil?, ctx.extra_chain_cert.nil?]
exchange(ctx, false)
exchange(ctx, true)

# The same certificate and key through the three writers.
ctx = OpenSSL::SSL::SSLContext.new
ctx.cert = leaf
ctx.key = key
ctx.extra_chain_cert = [ca]
p ctx.cert.to_der == leaf.to_der
exchange(ctx, false)

# add_certificate checks the key when it is called.
[OpenSSL::PKey.read(CA_KEY_PEM), OpenSSL::PKey.read(PUBLIC_PEM)].each do |wrong|
  begin
    OpenSSL::SSL::SSLContext.new.add_certificate(leaf, wrong)
  rescue ArgumentError => e
    p e.message
  end
end

# With no certificate there is nothing to agree on, and both ends raise.
exchange(OpenSSL::SSL::SSLContext.new, false)
