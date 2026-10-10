# spinel: share
# append_as_bytes with no argument appends nothing and answers its receiver,
# as concat and prepend do; on a frozen receiver it raises FrozenError. It was
# NoMethodError.
s = String.new("ab")
p s.append_as_bytes
x = s.append_as_bytes
p x, s
s.append_as_bytes
p s
p s.append_as_bytes(*[])
s.append_as_bytes(*[], "!")
p s
a = [String.new("x")]
p a[0].append_as_bytes, a
t = String.new("é")
p t.append_as_bytes.encoding, t.bytes
class Holder
  def initialize; @buf = String.new("ab"); end
  def touch = @buf.append_as_bytes
end
p Holder.new.touch
p s.concat, s.prepend
begin
  "lit".append_as_bytes
rescue => e
  p e.class
end
f = String.new("ab").freeze
begin
  f.append_as_bytes
rescue => e
  p e.class, e.message
end
# the answer is the receiver itself, so a call chained on it reaches the String
q = String.new("q")
q.append_as_bytes << "w"
p q
u = String.new("u")
u.append_as_bytes.append_as_bytes("v")
p u
