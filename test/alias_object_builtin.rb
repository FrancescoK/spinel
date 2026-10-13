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
