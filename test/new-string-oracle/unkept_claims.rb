# A method that keeps no reference to its parameter's String leaves no name
# holding the object that did not hold it when it was called. unkept_claims.claims
# claims that of every method here (the check is `unkept`); the oracle must
# disprove the ones that store the String, in a global, an ivar, a container an
# ivar holds, a constant's Array, a proc it keeps, or through a block it
# yields to, and not the ones that read it, change it in place, copy it,
# answer it, pass it down a recursion, or store it where it was already held.
$g = nil
$y = nil
LIST = []

def peek(s) = s.size
def shout(s)
  t = s.dup
  t << "!"
  t
end
def touch(s)
  s << "x"
  s.size
end
def same(s) = s
def down(s, n) = n == 0 ? s.size : down(s, n - 1)
def to_global(s)
  $g = s
  nil
end
def to_list(s) = LIST << s
def pass(s) = yield(s)
def pass_nothing(s) = yield(s.size)

class Box
  def initialize
    @box = {}
    @kept = nil
    @blk = nil
  end

  def to_ivar(s)
    @kept = s
    nil
  end

  def to_box(s)
    @box[:k] = s
    nil
  end

  def to_proc_ivar(s)
    @blk = proc { s }
    nil
  end

  def restore(s)
    @kept = s
    nil
  end
end

a = +"alpha"
b = Box.new
p peek(a), shout(a), touch(a), same(a).equal?(a), down(a, 3)
to_global(+"g")
to_list(+"l")
pass(+"y") { |v| $y = v }
p pass_nothing(+"ny") { |n| n + 1 }
b.instance_variable_set(:@kept, a)
b.restore(a)
b.to_ivar(+"i")
b.to_box(+"x")
b.to_proc_ivar(+"c")
p $g, LIST, $y
