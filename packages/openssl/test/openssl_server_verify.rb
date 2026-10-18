# verify_mode on a server (4a in #9341): a server asks for a client
# certificate once the program has set verify_mode, and checks the one it
# gets against its cert_store; a client sends the certificate its context
# holds to a server that asks. Each case is a handshake on loopback, a
# server thread and a client in this one, and a line each way over it.
require "openssl"
require "socket"

# The certificate for turn.jayang-dong.example and its key, and the Han
# River Test CA that issued it: the ones openssl_server_accept.rb uses.
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
# A client certificate for relay.gimpo.example, issued by the same CA for
# these tests and valid until 2126, and its P-256 key.
CLIENT_PEM = <<~PEM
-----BEGIN CERTIFICATE-----
MIIBbzCCARSgAwIBAgICDZYwCgYIKoZIzj0EAwIwHDEaMBgGA1UEAwwRSGFuIFJp
dmVyIFRlc3QgQ0EwIBcNMjYxMDE4MDc0NDM5WhgPMjEyNjA5MjQwNzQ0MzlaMB4x
HDAaBgNVBAMME3JlbGF5LmdpbXBvLmV4YW1wbGUwWTATBgcqhkjOPQIBBggqhkjO
PQMBBwNCAASYNQdzYEW3UG5uTdNaNXnxgnYimjQ3EPyCazKBizPI1/sa83RYiAbi
iLJwA/nhdNsD7UWdOGmbMUHS3Yq5BPlGo0IwQDAdBgNVHQ4EFgQUSxATrJm3eVZB
Y9gKJOJOgMKMFwYwHwYDVR0jBBgwFoAUo7o0xHGKl148fp+sAvzMDi+VStEwCgYI
KoZIzj0EAwIDSQAwRgIhAO8vpRDua2ztaC8/svak1/7J1dY6Sc7w/zhPOkrKMvXH
AiEAlR5zo5FldeQdmTv8xMkUMApKwgT5BkJ9zTy3o6Ost7A=
-----END CERTIFICATE-----
PEM
CLIENT_KEY_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIC6Le/KNXBgrpXVJKO9xa+8zyfT3yzeh5l/v0wAjkJqdoAoGCCqGSM49
AwEHoUQDQgAEmDUHc2BFt1Bubk3TWjV58YJ2Ipo0NxD8gmsygYszyNf7GvN0WIgG
4oiycAP54XTbA+1FnThpmzFB0t2KuQT5Rg==
-----END EC PRIVATE KEY-----
PEM

LEAF = OpenSSL::X509::Certificate.new(LEAF_PEM)
KEY = OpenSSL::PKey.read(KEY_PEM)
CA = OpenSSL::X509::Certificate.new(CA_PEM)
CLIENT = OpenSSL::X509::Certificate.new(CLIENT_PEM)
CLIENT_KEY = OpenSSL::PKey.read(CLIENT_KEY_PEM)

def server_ctx(store)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.add_certificate(LEAF, KEY)
  ctx.cert_store = store
  ctx
end

# One connection. The client does not verify the server: what is checked is
# what the server asks of the client. Under TLS 1.3 a client finishes its
# side of the handshake before the server checks its certificate, so a
# refusal reaches the client at its read, as an error or as no reply, and it
# reaches the server as an error or as the reset of the client's close;
# each end reports only whether it got through.
def exchange(server_ctx, with_cert)
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
      "refused"
    ensure
      sock.close
    end
  end

  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  if with_cert
    ctx.cert = CLIENT
    ctx.key = CLIENT_KEY
  end
  sock = TCPSocket.new("127.0.0.1", port)
  ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
  reply = nil
  begin
    ssl.connect
    ssl.write("Incheon\n")
    reply = ssl.gets
  rescue OpenSSL::SSL::SSLError, SystemCallError
    reply = nil
  ensure
    ssl.close
  end
  sock.close
  p [reply.nil? ? "no reply" : reply, t.value]
  server.close
end

store = OpenSSL::X509::Store.new
store.add_cert(CA)

# A server whose verify_mode was never set asks for no certificate, so the
# client's is not sent, and the empty store it would fail against is not
# consulted.
exchange(server_ctx(nil), true)

# Once it is set, the server asks, and checks what it gets against its
# cert_store: one with nothing in it trusts nothing.
ctx = server_ctx(nil)
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
exchange(ctx, true)

# A store holding the CA that issued the client's certificate.
ctx = server_ctx(store)
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
exchange(ctx, true)

# VERIFY_PEER asks without requiring: a client with no certificate gets
# through, unless VERIFY_FAIL_IF_NO_PEER_CERT is set as well.
exchange(ctx, false)
ctx = server_ctx(store)
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
exchange(ctx, false)
exchange(ctx, true)

# set_params sets verify_mode through its writer, as CRuby's does, so a
# server context it is called on asks too.
ctx = server_ctx(nil)
ctx.set_params
p ctx.verify_mode
exchange(ctx, true)
