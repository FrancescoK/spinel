# A yielding initialize that constructs its own class (`Y.new(a, b)` inside
# Y#initialize), or another class whose initialize leads back to it. A `new`
# site splices the yielding body, so the inner site was spliced again inside
# it, without end: spinel nested one level per splice until its rename table
# ran out, and with two such sites the work doubled at every level, so it
# never finished. Such a site now runs the body through the constructor (the
# initialize's proc-form clone), with the site's block, if any, as a proc.
# spinel: gc-stress
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
# The forwarded block writes a local of its caller: one variable at every
# level, with `&blk` and with an anonymous `&`.
total = 0
P.new(3) { |x| total += x }
p total
class PA
  def initialize(x, &)
    PA.new(x - 1, &) if x > 0
    yield x if block_given?
  end
end
total = 0
PA.new(4) { |x| total += x }
p total
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

# Two classes building each other: dead sites, and sites 80 levels deep.
class A1
  def initialize(a, b)
    B1.new(:dead, b) if ARGV.length == 9123
    B1.new(a, :dead) if ARGV.length == 9123
    yield [a, b]
  end
end
class B1
  def initialize(a, b)
    A1.new(:dead, b) if ARGV.length == 9123
    A1.new(a, :dead) if ARGV.length == 9123
    yield [a, b]
  end
end
A1.new(1, 2) { |y| p y }
$n = []
class A2
  def initialize(a)
    B2.new(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
class B2
  def initialize(a)
    A2.new(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
A2.new(0) { |a| p [:a2, a] }
p $n

# A parent's initialize building a subclass whose initialize calls super:
# dead sites, a few levels, and 80.
class SP
  def initialize(a, b)
    SC.new(:dead, b) if ARGV.length == 9123
    SC.new(a, :dead) if ARGV.length == 9123
    yield [a, b]
  end
end
class SC < SP
  def initialize(a, b)
    super
  end
end
SP.new(1, 2) { |y| p y }
SC.new(3, 4) { |y| p y }
class TP
  def initialize(a, lim)
    TC.new(a + 1, lim) { |q| $n << q } if a < lim
    yield a
  end
end
class TC < TP
  def initialize(a, lim)
    super(a, lim) { |q| yield q + 100 }
  end
end
$n = []
TP.new(0, 4) { |a| p [:tp, a] }
p $n
$n = []
TP.new(0, 80) { |a| p [:tp, a] }
p $n.size, $n.first, $n.last

# The same through an included module's initialize, reached by `new` from
# a class without its own and by `super` from a class with one: dead
# sites, then 80 deep with a bare super and with a super block.
module MI
  def initialize(a, b)
    MB.new(:dead, b) if ARGV.length == 9123
    MB.new(a, :dead) if ARGV.length == 9123
    yield a, b
  end
end
class MA
  include MI
end
class MB
  include MI
  def initialize(a, b)
    super
  end
end
MA.new(1, 2) { |x, y| p [x, y] }
MB.new(3, 4) { |x, y| p [x, y] }
module MJ
  def initialize(a)
    MC.new(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    MD.new(a + 1) { |q| $n << -q } if a == 40
    yield a
  end
end
class MC
  include MJ
  def initialize(a)
    super
  end
end
class MD
  include MJ
  def initialize(a)
    super(a) { |q| yield q }
  end
end
$n = []
MC.new(0) { |a| p [:mc, a] }
p $n

# The `new` in a yielding method that the initialize calls: an instance
# method (dead sites, and 80 deep), a top-level method, a class method
# with a bare `new`, and another object's method.
class YH
  def mk(a, b) = YH.new(a, b) { |q| yield q }
  def initialize(a, b)
    mk(:dead, b) { |q| q } if ARGV.length == 9123
    mk(a, :dead) { |q| q } if ARGV.length == 9123
    yield [a, b]
  end
end
YH.new(1, 2) { |y| p y }
class YI
  def mk(a)
    YI.new(a) { |q| yield q }
  end
  def initialize(a)
    mk(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
$n = []
YI.new(0) { |a| p [:yi, a] }
p $n
def build_yt(a, b)
  yield
  YT.new(a, b) { |q| q }
end
class YT
  def initialize(a, b)
    build_yt(:dead, b) { 1 } if ARGV.length == 9123
    build_yt(a, :dead) { 2 } if ARGV.length == 9123
    yield [a, b]
  end
end
YT.new(1, 2) { |y| p y }
class YC
  def self.make(a) = new(a) { |q| yield q }
  def initialize(a)
    YC.make(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
$n = []
YC.new(0) { |a| p [:yc, a] }
p $n
class YO
  def mk(a) = YP.new(a) { |q| yield q }
end
class YP
  def initialize(a)
    YO.new.mk(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
$n = []
YP.new(0) { |a| p [:yp, a] }
p $n

# A class whose own `self.new` yields (no initialize) and builds the class
# that built it: dead sites, and 80 deep.
class SA
  def initialize(a, b)
    SB.new(:dead, b) { |q| q } if ARGV.length == 9123
    SB.new(a, :dead) { |q| q } if ARGV.length == 9123
    yield [a, b]
  end
end
class SB
  def self.new(a, b)
    yield a
    SA.new(a, b) { |q| q }
  end
end
SA.new(1, 2) { |y| p y }
class SC1
  def initialize(a)
    SD.new(a + 1) { |q| $n << q if q % 20 == 0 } if a < 80
    yield a
  end
end
class SD
  def self.new(a)
    yield a
    SC1.new(a) { |q| q }
  end
end
$n = []
SC1.new(0) { |a| p [:sc, a] }
p $n

# Class#new reached through a class's own new still runs that method first,
# including its replacement block. Dead sites and 80 live levels.
class NS
  attr_reader :a
  def self.new(a) = super(a) { |q| q }
  def initialize(a)
    @a = a
    NS.new(a) if ARGV.length == 9123
    NS.new(a) if ARGV.length == 9123
    NS.new(a + 1) if a < 80
    $n << a if a % 20 == 0
    yield a
  end
end
$n = []
p NS.new(0).a
p $n

# A yielding new has a constructor edge at its super too, for the class
# itself and a descendant inheriting the method with its own initialize.
class NSP
  def self.new(a)
    yield a if block_given?
    super(a) { |q| $n << q if q % 20 == 0 }
  end
  def initialize(a)
    NSP.new(a) if ARGV.length == 9123
    NSP.new(a) if ARGV.length == 9123
    NSP.new(a + 1) if a < 80
    yield a
  end
end
class NSC < NSP
  def initialize(a)
    NSC.new(a) if ARGV.length == 9123
    NSC.new(a) if ARGV.length == 9123
    NSC.new(a + 1) if a < 80
    yield a
  end
end
$n = []
NSP.new(0) { |a| p [:nsp, a] }
p $n
$n = []
NSC.new(0) { |a| p [:nsc, a] }
p $n

# The cycle's clone supers into a yielding module that is outside the
# cycle and has no clone. Keep that shadow, including when a parent also
# has initialize; the caller's block must reach the module's yield.
module OutsideCycle
  def initialize(a)
    pair = [a, a + 100]
    yield pair
  end
end
module OutsideMiddle
  def initialize(a)
    super(a) { |q| yield [q[0], q[1] + 1000] }
  end
end
class OutsideParent
  def initialize(a)
    p [:wrong_parent, a]
  end
end
class IncludedCycle < OutsideParent
  include OutsideCycle
  include OutsideMiddle
  def initialize(a)
    IncludedCycle.new(a) if ARGV.length == 9123
    IncludedCycle.new(a) if ARGV.length == 9123
    IncludedCycle.new(a + 1) { |q| $n << q if q[0] % 20 == 0 } if a < 80
    super
  end
end
$n = []
IncludedCycle.new(0) { |q| p [:included, q] }
p $n
class ExplicitCycle
  include OutsideCycle
  def initialize(a, &blk)
    ExplicitCycle.new(a + 1, &blk) if a < 3
    super(a) { |q| yield [q[0], q[1] + 100] }
  end
end
total = 0
ExplicitCycle.new(0) { |q| total += q[1] }
p total

# The same shadow path through a prepend, forwarding both an explicit
# block argument and no block (which raises at the shadow's yield).
module PrependedCycle
  def initialize(a, &blk)
    PrependTarget.new(a + 1, &blk) if a < 80
    super(a, &blk)
  end
end
class PrependTarget
  prepend PrependedCycle
  def initialize(a)
    yield a
  end
end
$n = []
PrependTarget.new(0) { |q| $n << q if q % 20 == 0 }
p $n
begin
  PrependTarget.new(80)
rescue LocalJumpError => e
  p [e.class, e.message]
end
