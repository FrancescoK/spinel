# In an instance_eval block on an Array, Hash or String subclass instance,
# a receiverless call goes through the receiver's chain: the class, its
# builtin, Enumerable, then Object. A top-level def is Object's, so a method
# of the program's Enumerable and String's own dup come ahead of it.

module Enumerable
  def bar = :enum
  def baz(x) = x * 2
  def qux = :enum_qux
end

class H < Hash; end
class A < Array; end
class S < String; end
class K < Hash
  def qux = :k_qux
end
class Array
  def qux = :array_qux
end

def bar = :top
def baz(x) = :top
def qux = :top
def dup = :top

p H.new.instance_eval { bar }
p A.new.instance_eval { bar }
p H.new.instance_exec(3) { |x| baz(x) }
p A.new.instance_eval { baz(5) }

# the class and the builtin's reopen come ahead of Enumerable
p K.new.instance_eval { qux }
p A.new.instance_eval { qux }
p H.new.instance_eval { qux }

# String has its own dup; Hash and Array take dup from Kernel
s = S.new("ab")
d = s.instance_eval { dup }
p d, d.class, d.equal?(s)
d << "c"
p s
p H.new.instance_eval { dup }
p A.new.instance_eval { dup }

# a method call with a receiver is not changed
p H.new.bar
p [1, 2].instance_eval { bar }
