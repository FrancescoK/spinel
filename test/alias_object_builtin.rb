# An alias of an Object / Kernel method a program class has not defined
# (`alias original_dup dup`) calls the builtin, even where the class
# defines its own method of the name after the alias, as CRuby's alias
# keeps the body in effect where it appeared. An alias of a method an
# ancestor or an included module defines names that method.
class N
  def initialize(x)
    @x = x
    freeze
  end
  attr_reader :x
  alias original_dup dup
  alias original_clone clone
  def dup = self
  def od = original_dup
  def oc = self.original_clone
end
n = N.new(1)
p n.od.equal?(n), n.od.frozen?, n.od.x
p n.oc.equal?(n), n.oc.frozen?
p n.dup.equal?(n)

class Plain
  def initialize = @x = 1
  alias copy dup
  alias old_to_s to_s
  alias old_inspect inspect
  alias same ==
  alias old_hash hash
end
a = Plain.new
p a.copy.class, a.copy.equal?(a)
p a.old_to_s.start_with?("#<Plain"), a.old_inspect.start_with?("#<Plain")
p a.same(a), a.same(Plain.new)
p a.old_hash == a.hash

class Other
  def to_s = "other"
end
class P
  def to_s = "P#to_s"
end
class Q < P
  alias old_to_s to_s
end
module Mx
  def inspect = "Mx#inspect"
end
class R
  include Mx
  alias old_inspect inspect
end
p Q.new.old_to_s, R.new.old_inspect, Other.new.to_s

# an alias an ancestor declared reaches a subclass that declares none
class Base
  attr_reader :v
  def initialize(v) = (@v = v)
  alias original_dup dup
  def dup = "own dup"
end
class Sub < Base; end
p Sub.new(1).original_dup.class, Sub.new(2).original_dup.v, Base.new(3).original_dup.class

# a method a module brings or an ancestor gets after the alias is not the
# one the alias took
module Late
  def dup = "Late#dup"
end
class Before
  alias old_dup dup
  include Late
end
p Before.new.old_dup.class, Before.new.dup
class Root; end
class Leaf < Root; end
class Leaf
  alias old_dup dup
end
class Root
  def dup = "Root#dup"
end
p Leaf.new.old_dup.class, Leaf.new.dup

# a receiverless call of the alias inside the class: the ancestor's method
# where one defined it before the alias, the builtin otherwise
class Named
  def to_s = "Named#to_s"
end
class Child < Named; end
class Child
  alias old_to_s to_s
  def show = old_to_s
end
class Own
  alias old_dup dup
  def initialize = (@v = 1)
  def copy = old_dup
  def dup = "own dup"
end
p Child.new.show, Own.new.copy.class, Own.new.dup
