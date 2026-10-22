# OpenSSL::Digest#digest and #hexdigest given data answer the digest of that
# data alone and reset the object, so what it was fed before is dropped.
require "openssl"

["SHA256", "SHA1", "MD5"].each do |name|
  d = OpenSSL::Digest.new(name)
  d << "abc"
  p d.hexdigest("x") == OpenSSL::Digest.new(name).hexdigest("x")
  p d.hexdigest == OpenSSL::Digest.new(name).hexdigest("")
  d << "abc"
  p d.digest("x") == OpenSSL::Digest.new(name).digest("x")
  p d.hexdigest == OpenSSL::Digest.new(name).hexdigest("")
  d << "y"
  p d.hexdigest == OpenSSL::Digest.new(name).update("y").hexdigest
end
