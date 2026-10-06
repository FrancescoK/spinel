# Flag-only: without the flag (as on master) the second object's and the subclass's ivars hold copies.
# An ivar is a slot per object: a String one object's slot holds, written
# into another's, is one String with two names. A superclass's ivar is the
# subclass's slot. An ivar that also holds nil keeps its String's handle.
class K
  def initialize(v) = @v = v
  def v = @v
  def put(x) = @v = x
  def bang = @v << "!"
end
k1 = K.new(+"a")
k2 = K.new(+"b")
k2.put(k1.v)
k2.bang
p k1.v, k2.v

class A
  def initialize(s) = @k = s
end
class B < A
  def bang = @k << "?"
end
s = +"s"
B.new(s).bang
p s

class N
  def set(x) = @n = x
  def clear = @n = nil
  def add = (@n << "+" if @n)
  def n = @n
end
o = N.new
t = +"t"
o.set(t)
o.add
p t
o.clear
p o.n
# an attr_accessor ivar with no initializer is a box (it holds nil too)
class KB
  attr_accessor :v
  def bang = @v << "!"
end
b1 = KB.new; b1.v = +"a"
b2 = KB.new; b2.v = b1.v
b2.bang
p b1.v
# two shared reads in one call's arguments
u = +"u"
w = u
w << "!"
p (u..u)
