# OpenSSL::Random.random_bytes answers that many binary bytes, a fresh
# draw each call; zero is an empty String and a negative length raises
# ArgumentError, as CRuby's does. Kernel#rand and ::Random are untouched.
require "openssl"

a = OpenSSL::Random.random_bytes(16)
b = OpenSSL::Random.random_bytes(16)
p [a.bytesize, a.encoding == Encoding::BINARY, a == b]
p OpenSSL::Random.random_bytes(0)
begin
  OpenSSL::Random.random_bytes(-1)
rescue ArgumentError => e
  p e.class
end
p Random.new(42).rand(1000) == Random.new(42).rand(1000)
p rand(5).between?(0, 4)
