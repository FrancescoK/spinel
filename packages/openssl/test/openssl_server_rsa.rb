# A context given an RSA key and the certificate for it, the form most HTTPS
# certificates still take: the server presents it, and a client that trusts
# the Han River Test CA verifies it, name and all. The same certificate then
# serves as a client's, to a server that asks for one.
require "openssl"
require "socket"

# A certificate for turn.jayang-dong.example over the 2048-bit key of
# openssl_pkey_rsa.rb, issued by the Han River Test CA for these tests and
# valid until 2126.
RSA_LEAF_PEM = <<~PEM
-----BEGIN CERTIFICATE-----
MIICPTCCAeSgAwIBAgICAbswCgYIKoZIzj0EAwIwHDEaMBgGA1UEAwwRSGFuIFJp
dmVyIFRlc3QgQ0EwIBcNMjYxMDE4MDg0OTA1WhgPMjEyNjA5MjQwODQ5MDVaMCMx
ITAfBgNVBAMMGHR1cm4uamF5YW5nLWRvbmcuZXhhbXBsZTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAK4oca3V25Ney0M0QF8zAhljoR7ffeSAqtqFw4eq
kY4gg7HFqsgEEicPVhlH7fxH2g27S1uJS2Wm86nQI7yjMqS2wiJ5vrrvOtwZXIj/
8pOC3HzFodqZy7+N/CNtY1hvG3PtXHY8zg07c4T1wAPVyP0nHbRuLLpVDIlwFguO
Q10glhdYnHkiPahq3C8Uk3TpatfOEZ55/DnvJ9aK+O7eoFq13LxgHSe9nXtAGrvI
SitZcI4fvFw4KgsAW7ygoZU/b/90BaO7NGfo8CGMnn1Gg6mjWPpuMpgm1QM/D6F6
rtAXXvle/uwpzMujxLKfbGsaXosLf9PIcnqDOFdDNaj0Yf0CAwEAAaNCMEAwHQYD
VR0OBBYEFNy4oQ5jOP8hoYTyXeneW20RycZ0MB8GA1UdIwQYMBaAFKO6NMRxipde
PH6frAL8zA4vlUrRMAoGCCqGSM49BAMCA0cAMEQCIGa/p67B05KPPnltd7SYJJWF
IvvgFCK01f5VGd51MWhqAiBLdLx6NPqD0svyijFn89Vs/NCLxTGb+v/6wlhM/Nli
pA==
-----END CERTIFICATE-----
PEM
RSA_KEY_PEM = <<~PEM
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCuKHGt1duTXstD
NEBfMwIZY6Ee333kgKrahcOHqpGOIIOxxarIBBInD1YZR+38R9oNu0tbiUtlpvOp
0CO8ozKktsIieb667zrcGVyI//KTgtx8xaHamcu/jfwjbWNYbxtz7Vx2PM4NO3OE
9cAD1cj9Jx20biy6VQyJcBYLjkNdIJYXWJx5Ij2oatwvFJN06WrXzhGeefw57yfW
ivju3qBatdy8YB0nvZ17QBq7yEorWXCOH7xcOCoLAFu8oKGVP2//dAWjuzRn6PAh
jJ59RoOpo1j6bjKYJtUDPw+heq7QF175Xv7sKczLo8Syn2xrGl6LC3/TyHJ6gzhX
QzWo9GH9AgMBAAECggEAF/5gcwekobAMpuya9cKsRl0whHVb/dAwObz2DEnWldMq
8aH+/mF5MsJtJTyAsCIiC4RDRJAswAt5RGr1kXaWcpTvOBq3yT9OR6aC1ikU/Xeo
8tOzkc9gf7qLA0J9zmA4UwdflraX2MDZEHdfBeg9MYtjD0miheVTvdegYeUuqLSr
Qq7oso4vr6dsQsg8+mVWfeofnbDie8AUjiY7NeGAEp7jA61fDgVulcbX/hi42q7V
qODfFpjs6fBxGa6zbDMhWz6dqDa7PTH5ne4A6TqWfdg0cvZfkD6H/0uop3csmIfH
TfFh+EFyDVvMli030TTNwe0JT/SwzKaBhbbRbpqWDQKBgQDjMTlFdj8iRN73G1yI
mfHYJBJ9pcCaWoVN8P8zGebefpaJjWNo+NToTxO+D9wUjp5tI3l9DeUwhtUAJJIs
V9pEq8MzIM4ROmcXGfbJNlKd00reYtUCJrSCzyt8Ivj5tEaf1sHfIn+fyRRiHeC9
0DPLwdZfaO3Ox65UlLeRrjEkpwKBgQDEPbNGhmRcokKpRkljGbtaspTGpNAsWjka
gb/KXX8Atxgpdc1cnicYfMwcHQC9Cx4uxs9qusY3KOQFMtdzM4M8cQl083of3M7q
skDVx+qw48sopaNhpYdLqKVP+2DmtOITNcLO0lQ6mMAnaKlN0u/nDxqNk7X1HnOF
Mjf3aSQEuwKBgFf8h0acfeTisUsYAKUyoZPonHSmzcm5hujhjaQXwu6mLdzFshtE
SwhRH7862yvm8/omg/VnfTxm63TrtOSRfYmcz7MsYEIR0T0EJCxW6nYPD27C7eWw
YbZLT3b7AFuMctGSVXD6Jl0Wfdtl4NUCHh0qS8CVnYu4j45YLiOwR33/AoGAOAAb
fs6vKTgsqb2jB6K6MmGvzxgNR/rfPM81+fvAWGXngT1aw0lmgrhqTsOACHJ5xIN7
gUuXcPo8R7eAgCF9G+xt9G/es+UBLzx7AAay1JPMz+akvyLLfy27Lx3fQzbvJOg8
lWS0IJyiiRx24/yD9X3759b1H+P2t1XjXrkkTC0CgYBBtnkV+zDGR4SoublalEPx
irE3XvK2IkyDMKFUaCGshVgZ0h4co7wKL3Nyh1i/8PHn914ak77Gh9gMgcLitNgz
kKJEgovRpvFnTvc6ivVxdkMjA0a0C+6xlCDuPML7yy32hONbXgMrUdFcm/49lgIy
M3S+PteQRbYKXCT1Vl48eQ==
-----END PRIVATE KEY-----
PEM
# The EC certificate and key of openssl_server_accept.rb, and their CA.
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

RSA_LEAF = OpenSSL::X509::Certificate.new(RSA_LEAF_PEM)
RSA_KEY = OpenSSL::PKey.read(RSA_KEY_PEM)
EC_LEAF = OpenSSL::X509::Certificate.new(LEAF_PEM)
EC_KEY = OpenSSL::PKey.read(KEY_PEM)
STORE = OpenSSL::X509::Store.new
STORE.add_cert(OpenSSL::X509::Certificate.new(CA_PEM))

# to_der is CRuby's: the private key as PKCS#1, its public half as a
# SubjectPublicKeyInfo. The digests are the same bytes CRuby writes.
p OpenSSL::Digest::SHA256.hexdigest(RSA_KEY.to_der)
p OpenSSL::Digest::SHA256.hexdigest(RSA_KEY.public_key.to_der)
p OpenSSL::PKey.read(RSA_KEY.to_der).private?

# One connection, with a client that verifies the server.
def exchange(server_ctx, client_cert = nil, client_key = nil)
  server = TCPServer.new("127.0.0.1", 0)
  port = server.addr[1]
  t = Thread.new do
    sock = server.accept
    ssl = OpenSSL::SSL::SSLSocket.new(sock, server_ctx)
    begin
      ssl.accept
      ssl.write("Han River: #{ssl.gets}")
      ssl.close
      "accepted"
    rescue OpenSSL::SSL::SSLError, SystemCallError
      "refused"
    ensure
      sock.close
    end
  end

  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
  ctx.verify_hostname = true
  ctx.cert_store = STORE
  if client_cert
    ctx.cert = client_cert
    ctx.key = client_key
  end
  sock = TCPSocket.new("127.0.0.1", port)
  ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
  ssl.hostname = "turn.jayang-dong.example"
  reply = nil
  begin
    ssl.connect
    ssl.write("Seoul\n")
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

ctx = OpenSSL::SSL::SSLContext.new
p ctx.add_certificate(RSA_LEAF, RSA_KEY).equal?(ctx)
exchange(ctx)

ctx = OpenSSL::SSL::SSLContext.new
ctx.cert = RSA_LEAF
ctx.key = RSA_KEY
exchange(ctx)

# add_certificate checks an RSA key as it checks an EC one.
[[EC_LEAF, RSA_KEY], [RSA_LEAF, EC_KEY], [RSA_LEAF, RSA_KEY.public_key]].each do |cert, key|
  begin
    OpenSSL::SSL::SSLContext.new.add_certificate(cert, key)
  rescue ArgumentError => e
    p e.message
  end
end

# The RSA certificate as a client's, to an EC server that requires one.
ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(EC_LEAF, EC_KEY)
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
ctx.cert_store = STORE
exchange(ctx, RSA_LEAF, RSA_KEY)
exchange(ctx)
