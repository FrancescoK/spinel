# In an instance_eval block on an Array, Hash or String subclass instance,
# a receiverless call to a name the builtin defines reaches the builtin's
# method, even where a top-level def has that name: the top-level def is
# Object's, and Hash, Array and String come first in the chain. A name the
# builtin takes from Kernel (frozen?, is_a?) still reaches the top-level def.
class H < Hash; end
class A < Array; end
class S < String; end
class H2 < Hash
  def size = :own
end
module M
  def size = :mod
end
class HM < Hash
  include M
end
class K; end

def size = :top
def first = :top
def length = :top
def keys = :top
def to_s = "top"
def map = :top
def frozen? = :top_frozen
def is_a?(k) = :top_is_a

h = H.new
h[:a] = 1
p h.instance_eval { size }
p h.instance_exec(2) { |x| size + x }
p h.instance_eval { keys }
p h.instance_eval { to_s }
p h.instance_eval { -> { size }.call }
p H2.new.instance_eval { size }
p HM.new.instance_eval { size }
p A.new([1, 2]).instance_eval { first }
p A.new([1, 2]).instance_eval { map { |x| x * 2 } }
p S.new("ab").instance_eval { length }
p({}.instance_eval { size })

def run(x) = x.instance_eval { size }
p run(H.new)

# in a class body, the block's self is still its receiver, not the class
class C
  def self.size = :cls
  N = H.new.instance_eval { size }
end
p C::N

# Kernel's names: the top-level def wins
p h.instance_eval { frozen? }
p h.instance_eval { is_a?(Hash) }
p K.new.instance_eval { frozen? }
p K.new.instance_eval { to_s }

# outside instance_eval, the top-level def answers
p size
