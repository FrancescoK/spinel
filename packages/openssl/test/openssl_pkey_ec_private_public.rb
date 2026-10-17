# PKey::EC#private? and #public?, and their aliases private_key? and
# public_key?, on a generated key and on keys PKey.read gives back from a
# private and a public PEM.
require "openssl"

# The P-256 key behind the turn.jayang-dong.example certificate in
# openssl_x509_certificate.rb, as SEC1 and as its public half.
SEC1_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIPIRlQfBz7+HavOzW8H69dntBcUZ0MicF3/FxGctM0W1oAoGCCqGSM49
AwEHoUQDQgAEt359v/oOHu/SPzBOr2L2kyeBh0FqfJEb4bHSE1VYY91cbq+WbMQM
1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END EC PRIVATE KEY-----
PEM
PUBLIC_PEM = <<~PEM
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEt359v/oOHu/SPzBOr2L2kyeBh0Fq
fJEb4bHSE1VYY91cbq+WbMQM1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END PUBLIC KEY-----
PEM

generated = OpenSSL::PKey::EC.generate("prime256v1")
private_key = OpenSSL::PKey.read(SEC1_PEM)
public_key = OpenSSL::PKey.read(PUBLIC_PEM)

[generated, private_key, public_key].each do |key|
  p [key.private?, key.public?, key.private_key?, key.public_key?]
end

# A server picks the key it will sign with by asking, before a handshake
# needs one.
signer = [public_key, private_key].find { |key| key.private? }
p signer.equal?(private_key)
