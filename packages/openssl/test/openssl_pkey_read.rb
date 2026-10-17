# PKey.read over the forms an EC key is stored in: a SEC1 and a PKCS#8
# private key and a public key, each as PEM and as DER, and PKeyError for
# what is not a key.
require "openssl"

# A P-256 key made for these tests and used nowhere else: the one behind the
# turn.jayang-dong.example certificate in openssl_x509_certificate.rb.
SEC1_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIPIRlQfBz7+HavOzW8H69dntBcUZ0MicF3/FxGctM0W1oAoGCCqGSM49
AwEHoUQDQgAEt359v/oOHu/SPzBOr2L2kyeBh0FqfJEb4bHSE1VYY91cbq+WbMQM
1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END EC PRIVATE KEY-----
PEM
# The same key as PKCS#8, the form certbot writes to privkey.pem.
PKCS8_PEM = <<~PEM
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg8hGVB8HPv4dq87Nb
wfr12e0FxRnQyJwXf8XEZy0zRbWhRANCAAS3fn2/+g4e79I/ME6vYvaTJ4GHQWp8
kRvhsdITVVhj3Vxur5ZsxAzUoaUswcpE59n3VGgVJXZ8jgFs3Taaxxdg
-----END PRIVATE KEY-----
PEM
PUBLIC_PEM = <<~PEM
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEt359v/oOHu/SPzBOr2L2kyeBh0Fq
fJEb4bHSE1VYY91cbq+WbMQM1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END PUBLIC KEY-----
PEM
# `openssl ecparam -genkey` without -noout writes the curve's parameters
# ahead of the key.
PARAMS_PEM = <<~PEM
-----BEGIN EC PARAMETERS-----
BggqhkjOPQMBBw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIPIRlQfBz7+HavOzW8H69dntBcUZ0MicF3/FxGctM0W1oAoGCCqGSM49
AwEHoUQDQgAEt359v/oOHu/SPzBOr2L2kyeBh0FqfJEb4bHSE1VYY91cbq+WbMQM
1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END EC PRIVATE KEY-----
PEM

def der(pem) = pem.lines.reject { |l| l.start_with?("-----") }.join.unpack1("m")

[SEC1_PEM, PKCS8_PEM, PUBLIC_PEM, PARAMS_PEM].each { |pem| p OpenSSL::PKey.read(pem).class }
[SEC1_PEM, PKCS8_PEM, PUBLIC_PEM].each { |pem| p OpenSSL::PKey.read(der(pem)).class }

["Incheon Airport", ""].each do |bad|
  begin
    OpenSSL::PKey.read(bad)
  rescue OpenSSL::PKey::PKeyError => e
    p e.message
  end
end

p OpenSSL::PKey::PKeyError.superclass
