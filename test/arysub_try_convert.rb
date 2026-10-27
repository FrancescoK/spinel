# try_convert answers an Array, Hash or String subclass instance as it is,
# and never calls the class's own conversion.
class T < Array
  def tag = "T#{size}"
  def to_ary = [55]
end
t = T.new([1, 2])
r = Array.try_convert(t)
p r
p r.equal?(t)
p r.tag
class H < Hash
  def to_hash = {z: 0}
end
h = H.new
h[:a] = 1
p Hash.try_convert(h)
p Hash.try_convert(h).equal?(h)
class S < String; end
s = S.new("ab")
p String.try_convert(s)
p String.try_convert(s).equal?(s)
p Array.try_convert(h)
p Hash.try_convert(t)
p String.try_convert(t)

class U < T; end
u = U.new([3])
p Array.try_convert(u).class

class Box
  def initialize(t) = @t = t
  def conv = Array.try_convert(@t)
end
p Box.new(t).conv.equal?(t)

def via(x) = Hash.try_convert(x)
p via(h).class

maybe = ARGV.size > 5 ? t : nil
p Array.try_convert(maybe)
maybe2 = ARGV.size < 5 ? t : nil
p Array.try_convert(maybe2)

[t, t].each { |e| p Array.try_convert(e).size }
