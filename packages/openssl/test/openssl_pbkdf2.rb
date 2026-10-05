# PBKDF2 (#7206): OpenSSL::PKCS5.pbkdf2_hmac with a Digest, and
# OpenSSL::KDF.pbkdf2_hmac with a name, against CRuby's keys.
require "openssl"
digest = OpenSSL::Digest.new("SHA256")
p OpenSSL::PKCS5.pbkdf2_hmac("password", "salt", 4096, 32, digest).unpack1("H*")
p OpenSSL::KDF.pbkdf2_hmac("password", salt: "salt", iterations: 2, length: 40, hash: "SHA256").unpack1("H*")
p OpenSSL::PKCS5.pbkdf2_hmac_sha1("password", "salt", 2, 20).unpack1("H*")
p OpenSSL::KDF.pbkdf2_hmac("pw", salt: "s", iterations: 1, length: 10, hash: OpenSSL::Digest::SHA1.new).bytesize
