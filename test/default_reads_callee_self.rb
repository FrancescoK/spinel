# A parameter default is evaluated on the callee's self. Filled at the call
# site, some were rendered on the caller's: a keyword a `**` leaves out
# (`C.new.m(**h)` into `def m(k1: @d)`) read the caller's @d, and at the top
# level named no self at all, so the C did not compile. A constructor has no
# object at the call site yet, and `C.new(**h)`, `C.new(z: 1)` (which raises
# for its unknown key), `raise E, 1` and an exception's own `E.new` rendered
# a default reading the instance there all the same. Those constructions
# allocate first and run initialize on the fresh object, as a class's
# positional `.new` already did. An initialize taking a block does the same.
# spinel: gc-minor
class C
  def initialize = (@d = :callee)
  def m(k1: @d) = k1
  def rest(k1: @d, **o) = [k1, o]
  def pos(a = @d, b) = [a, b]
end

class D
  def initialize = (@d = :caller)
  def go(h) = C.new.m(**h)
  def go_rest(h) = C.new.rest(**h)
  def go_pos = C.new.pos(*[1])
end

d = D.new
p d.go({})
p d.go({k1: 1})
p d.go_rest({"s" => 1})
p d.go_pos

# the same from the top level, whose self has no @d
@d = :main
h = {}
p C.new.m(**h)
p C.new.rest(**{k1: 2, j: 3})

class K
  attr_reader :v
  def initialize(k1: @d) = (@v = [k1])
end
p K.new(**h).v
p K.new(**{k1: 4}).v
p((K.new(z: 1).v rescue $!.message))

class E < StandardError
  attr_reader :v
  def initialize(a = @q, b = 2) = (@v = [a, b]; super("e#{a.inspect}"))
end
p((begin; raise E; rescue E => e; [e.message, e.v]; end))
p((begin; raise E, 1; rescue E => e; [e.message, e.v]; end))
p E.new.v
k = [E][0]
p k.new.v, k.new(5).v

class F < StandardError
  def initialize(m = self.class.name) = super(m)
end
p((begin; raise F; rescue F => e; e.message; end))
p F.new.message, F.new.is_a?(StandardError)

class G < StandardError
  def initialize(k: @k) = super("g#{k.inspect}")
end
p((begin; raise G, 1; rescue => e; [e.class, e.message]; end))
p G.new.message, G.new(k: 7).message

# an initialize taking a block, and an exception's
class KB
  attr_reader :v
  def initialize(a = @q, k: @k, &b) = (@v = [a, k, b ? b.call : nil])
end
p KB.new.v, KB.new(1) { :blk }.v, KB.new(**{}).v
class EB < StandardError
  attr_reader :v
  def initialize(a = @q, b = 2, &blk) = (@v = [a, b, blk ? :blk : nil]; super("eb"))
end
p((begin; raise EB, 1; rescue EB => e; e.v; end))
p((begin; raise EB; rescue EB => e; e.v; end))
p EB.new { 1 }.v

# a splat's count is the run time's: any optional may be left to its default
class KS
  attr_reader :v
  def initialize(a, b = @q, c = 5) = (@v = [a, b, c])
end
e = []
p KS.new(1, *e).v, KS.new(*[1, 2]).v, KS.new(1, *[7, 8]).v
