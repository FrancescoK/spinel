# The left of a `||` answers the block itself where the block is set, so
# `@cb = blk || fallback` keeps the block and its parameters take whatever
# the later calls pass. The left of a `&&` answers the block only where it
# is nil or false, and a `||` a predicate reads drops its value, so neither
# of those keeps it.

class OrKept
  def initialize(&blk)
    blk.call(1, 2)
    @cb = blk || ->(a, b) { p [:fallback, a, b] }
  end
  def fire(a, b) = @cb.call(a, b)
end
OrKept.new { |a, b| p [a, b] }.fire("or", :or)

# the same through a local and through a global
class OrLocal
  def initialize(&blk)
    blk.call(3)
    q = blk || ->(a) { p [:fallback, a] }
    @cb = q
  end
  def fire(a) = @cb.call(a)
end
OrLocal.new { |a| p a }.fire("local")

def or_global(&b)
  b.call(4)
  $g = b || ->(a) { p [:fallback, a] }
end
or_global { |a| p a }
$g.call("global")

# returned through a `||`
def or_returned(&b)
  b.call(5)
  b || ->(a) { p [:fallback, a] }
end
or_returned { |a| p a }.call("returned")

# the left of `&&` does not keep it: the parameters stay where they are
def and_left(&b)
  b.call(6)
  p((b && :set))
end
and_left { |a| p a + 1 }

# a `||` a predicate reads does not keep it either
def or_pred(&b)
  b.call(7)
  p :yes if b || true
end
or_pred { |a| p a + 1 }

# a `||` nested in another predicate still does not keep it
def or_pred_nested(&b)
  b.call(8)
  p :deep if (b || true) && true
end
or_pred_nested { |a| p a + 1 }
