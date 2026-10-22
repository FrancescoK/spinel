# An Array of one class's objects read with a Range index answers the slice,
# as CRuby's does: the unboxed object array took the Range as an Integer
# index and raised TypeError (#9932), with or without a removal beside it.
class K
  attr_reader :n
  def initialize(n) = @n = n
end

a = [K.new(1), K.new(2)]
a.pop
p a[0..].size
b = [K.new(1), K.new(2), K.new(3)]
b.shift
p b[0..].map(&:n)
c = [K.new(1), K.new(2), K.new(3)]
c.delete_at(0)
p c[1..1].map(&:n)
d = [K.new(1), K.new(2)]
d.clear
p d[1..]
p d[0..]
e = [K.new(1), K.new(2)]
p e[0..].size
p e[5..]
p e[-1..].map(&:n)
