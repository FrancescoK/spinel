# OpenSSL::Digest#to_s (the hex digest) is a String, so requiring openssl
# leaves `x.to_s` on a boxed receiver a String everywhere else. While the
# hex digest was boxed, so was every such `to_s` in the program: here the
# byte it answers was boxed, and the Array `groups` names was copied to hold
# it, which lost the push.
require "openssl"

def first_byte(text)
  s = text.to_s
  s.getbyte(0)
end

def tail_size(gap, text)
  head = Array.new(0) { 0 }
  tail = Array.new(0) { 0 }
  tail << 1
  groups = gap ? tail : head
  groups << first_byte(text)
  tail.size
end

p tail_size(true, "a")
p tail_size(true, 7)
p tail_size(false, :sym)

d = OpenSSL::Digest::SHA256.new("abc")
p first_byte(d)
puts d.to_s
puts d.hexdigest
puts OpenSSL::Digest::SHA1.new("abc").hexdigest!
p d.to_s.bytesize
p d.hexdigest.bytesize
p OpenSSL::Digest::SHA1.new("abc").hexdigest!.bytesize
