# OpenSSL::Digest#to_s is the hex digest, #inspect shows the class and the
# hex digest, and #== compares another digest object by its digest and a
# String by the hex digest.
require "openssl"

d = OpenSSL::Digest::SHA256.new("abc")
puts d.to_s
puts "#{d}"
puts d.inspect
p d
puts OpenSSL::Digest.new("SHA1", "abc").inspect
puts OpenSSL::Digest::MD5.new.inspect

p d == d.hexdigest
p d == d.hexdigest.upcase
p d == d.digest
p d == OpenSSL::Digest::SHA256.new("abc")
p d == OpenSSL::Digest.new("SHA256", "abc")
p d == OpenSSL::Digest::SHA256.new("abd")
p d == OpenSSL::Digest::SHA1.new("abc")
p d == 1
p d == nil
p d != OpenSSL::Digest::SHA256.new
