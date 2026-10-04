# OpenSSL::Digest as an object (#7206): the algorithm by name or by class,
# update / << / digest / hexdigest / reset, and DigestError for an unknown one.
require "openssl"
digest = OpenSSL::Digest.new("SHA256")
p digest.digest_length, digest.name
p OpenSSL::Digest.new("SHA256").update("abc").digest.unpack1("H*")
d = OpenSSL::Digest::SHA256.new
d << "a"
d << "bc"
p d.hexdigest
p OpenSSL::Digest::SHA1.new("abc").hexdigest
p OpenSSL::Digest::SHA256.hexdigest("abc")
p d.reset.hexdigest
begin
  OpenSSL::Digest.new("NOPE")
rescue OpenSSL::Digest::DigestError => e
  p e.class
end
