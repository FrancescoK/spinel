# OpenSSL::Random.random_bytes answers that many binary bytes, a fresh
# draw each call, past the 256 bytes one native draw gives; zero is an
# empty String, a negative length raises ArgumentError and a String one
# TypeError, as CRuby's do. Kernel#rand and ::Random are untouched.
require "openssl"

a = OpenSSL::Random.random_bytes(16)
b = OpenSSL::Random.random_bytes(16)
p [a.bytesize, a.encoding == Encoding::BINARY, a == b]
p [255, 256, 257, 1024].map { |n| OpenSSL::Random.random_bytes(n).bytesize }
p OpenSSL::Random.random_bytes(1024).encoding == Encoding::BINARY
p OpenSSL::Random.random_bytes(0)
begin
  OpenSSL::Random.random_bytes(-1)
rescue ArgumentError => e
  p e.class
end
begin
  OpenSSL::Random.random_bytes("8")
rescue TypeError => e
  p e.class
end
p Random.new(42).rand(1000) == Random.new(42).rand(1000)
p rand(5).between?(0, 4)
