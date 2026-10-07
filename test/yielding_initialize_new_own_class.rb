# A yielding initialize that constructs its own class (`Y.new(a, b)` inside
# Y#initialize). A `new` site splices the yielding body, so the inner site
# was spliced again inside it, without end: spinel nested one level per
# splice until its rename table ran out, and with two such sites the work
# doubled at every level, so it never finished. Such a site now runs the
# body through the constructor (the initialize's proc-form clone), with
# the site's block, if any, as a proc.

# Two blockless sites that never run (the shape the dead-code probe made).
class Y
  def initialize(a, b)
    Y.new(:dead, b) if ARGV.length == 9123
    Y.new(a, :dead) if ARGV.length == 9123
    yield [a, b]
  end
end
Y.new(1, 2) { |y| p y }

# Sites that run: the inner object has no block, so its yield raises.
class L
  def initialize(a, b)
    L.new(a + 1, b) if a == 1
    L.new(a, b + 1) if b == 1
    yield [a, b]
  end
end
begin
  L.new(1, 2) { |y| p y }
rescue LocalJumpError => e
  p [e.class, e.message]
end
L.new(5, 6) { |y| p y }

# Deeper than the splices went: a block at the inner site, and an
# initialize that only yields when given one.
$n = []
class D
  def initialize(a)
    D.new(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
D.new(0) { |a| p [:blk, a] }
p $n
class E
  attr_reader :a
  def initialize(a)
    @a = a
    E.new(a + 1) if a < 70
    $n << a if a % 35 == 0
    yield a if block_given?
  end
end
p E.new(0).a
p $n

# The inner block reads the initialize's local and ivar at its own level;
# a subclass built there runs the same body.
class K
  attr_reader :v
  def initialize(a, b = a)
    @v = [a, b]
    k = a * 10
    K.new(a + 1, b) { |q| p [:inner, q.v, k, @v] } if a < 3
    J.new(a + 5) if a == 1
    yield self
  end
end
class J < K
end
begin
  K.new(1) { |y| p [:outer, y.v, y.class] }
rescue LocalJumpError => e
  p [e.class, e.message]
end

# The block forwarded with &blk, and a class inside a module.
class P
  attr_reader :x
  def initialize(x, &blk)
    @x = x
    P.new(x - 1, &blk) if x > 0
    yield x if block_given?
  end
end
P.new(3) { |x| p x }
p P.new(4).x
module M
  class Q
    def initialize(a, b)
      M::Q.new(:dead, b) if ARGV.length == 9123
      Q.new(a, :dead) if ARGV.length == 9123
      yield [a, b]
    end
  end
end
M::Q.new(1, 2) { |y| p y }
