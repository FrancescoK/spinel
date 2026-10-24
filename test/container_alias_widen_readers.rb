# An Array or Hash read out of an attribute or a Struct member into another
# name, or held as an element of an Array or a value of a Hash, is the same
# object: a push or a store of another kind through either name reaches the
# other. The reader's ivar now widens with the name it is written to, a
# Struct built from an Array takes that Array as it is, and an element read
# that is pushed widens the Arrays the element can be.

class Box
  attr_accessor :items
  def initialize(v) = @items = v
end

def show(x) = p(x)

# an attribute read into an ivar, a global and a local
b1 = Box.new([1])
@mine = b1.items
@mine << :sym
p b1.items
show(b1.items)
b2 = Box.new([2])
$g = b2.items
$g << "x"
p b2.items
b3 = Box.new([3])
x = b3.items
x << "s"
show(b3.items)

# a Struct member, both ways, and a Struct built from an attribute (a
# Struct class per shape: one member slot holds one kind)
S1 = Struct.new(:w)
s1 = S1.new([1])
K = s1.w
K << 2.5
p s1.w
S2 = Struct.new(:w)
s2 = S2.new([1])
l2 = s2.w
s2.w << [2]
p l2
S3 = Struct.new(:w)
la = [1.5]
s3 = S3.new(la)
s3.w << 2
p la
S4 = Struct.new(:w)
b4 = Box.new([4])
s4 = S4.new(b4.items)
s4.w << [5]
p b4.items
S5 = Struct.new(:w)
s5 = S5.new({k: 1})
l5 = s5.w
l5[2] = 2
p s5.w

# an element of an Array and a value of a Hash, pushed
a = [1]
e = [a]
e[0] << :t
p a
lb = [1]
eb = [lb]
eb[0] << 2.5
p lb
lh = [1]
h = {k: lh}
h[:k] << "s"
p lh

# a push of the same kind keeps the Array typed, and shared
b6 = Box.new([6])
@same = b6.items
@same << 7
p b6.items.sum

# An attribute whose writer is called, or which a subclass inherits, keeps
# answering as CRuby does: the reader's ivar widens only where every Array
# it holds can widen with it.
class Held
  attr_accessor :items
  def initialize(v) = @items = v
end
h1 = Held.new([1])
h1.items = [7]
@m1 = h1.items
@m1 << :s
p @m1
class Base
  attr_accessor :items
  def initialize = @items = [1]
end
class Derived < Base; end
d1 = Derived.new
@m2 = d1.items
@m2 << :x
p @m2, d1.items
S6 = Struct.new(:w)
s6 = S6.new([1])
s6.w = [5]
K6 = s6.w
K6 << 2.5
p K6
class Kept
  attr_accessor :items
  def initialize(v) = @items = v
end
S7 = Struct.new(:w)
l7 = [1]
k7 = Kept.new(l7)
s7 = S7.new(k7.items)
s7.w << [5]
p l7, k7.items
