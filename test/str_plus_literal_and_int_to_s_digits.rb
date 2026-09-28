# `str + "literal"` takes a fast path that knows the literal's length, and
# Integer#to_s / interpolation write digits two at a time into a string sized
# up front. Both must keep every byte, the encoding and the frozen state.

# the receiver's bytes and the literal's, including NULs on both sides
a = "x\0y"
r = a + "\0z"
p r, r.bytesize
p ("" + ""), ("" + "").bytesize
p (a + ""), ("" + "é").length

# a binary receiver stays binary; a text one stays text
b = "\xff".b
p (b + "q").encoding, ("q" + "r").encoding

# the result is a fresh, unfrozen copy
s = "ab".freeze
t = s + "c"
t << "!"
p s, t, t.frozen?

# a nil receiver is NoMethodError
n = [nil, "k"].first
begin
  n + "x"
rescue NoMethodError => e
  puts e.class
end

# chained and inside a loop that collects (GC pressure keeps the receiver live)
acc = []
300.times { |i| acc << (i.to_s + "-" + "x") }
p acc.first(3), acc.last, acc.size

# digit counts across every width, both signs
[0, 7, 9, 10, 42, 99, 100, 101, 999, 1000, 9999, 10000, 99999, 100000,
 1234567, 98765432, 123456789012, 9223372036854775807, -1, -9, -10,
 -99, -100, -1000, -123456789, -9223372036854775807].each do |v|
  s = v.to_s
  puts "#{s} #{s.size} [#{v}] #{s[0]}#{s[-1]}"
end
