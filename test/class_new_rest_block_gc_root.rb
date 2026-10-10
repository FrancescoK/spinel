# spinel: gc-stress
# A constructor allocates the object before initialize roots its
# parameters, so an argument the call makes fresh has to be rooted by the
# call until the constructor returns. The rest array of a `*rest`
# initialize was not: a splat's or a gather's array was rooted only inside
# its own statement expression, and a converted (`*strs`, `*[1, 2]`), copied
# (`new(1, *a)`) or empty rest not at all. Nor was a block's proc for a
# stored `&blk` (a literal block, or `&-> { }` into an initialize that calls
# it), nor the boxed arguments of a `new` on a receiver read out of a
# container. At SPINEL_GC_STRESS=2 the collector swept each of them before
# initialize stored it. A method's rest is no different: one that captures
# its rest in a lambda or a Thread allocates the cell before it stores the
# array, and a `&m` of a Method turns into a new proc.

class C
  def initialize(x, *ys) = (@x = x; @ys = ys)
  def to_s = "C(#{@x},#{@ys.inspect})"
end

class KB
  def initialize(x, *ys, k: 0, &b) = (@x = x; @ys = ys; @k = k; @b = b)
  def to_s = "KB(#{@x},#{@ys.inspect},#{@k.inspect},#{@b ? @b.call(7).inspect : "-"})"
end

class PO
  def initialize(x, *ys, z) = (@x = x; @ys = ys; @z = z)
  def to_s = "PO(#{@x},#{@ys.inspect},#{@z})"
end

# an initialize that calls its block: the constructor takes the proc
class PB
  def initialize(r, &b) = (@r = r; @tag = b.call)
  def to_s = "PB(#{@r},#{@tag.inspect})"
end

class Sub < KB
  def initialize(*a, &b) = super(*a, k: "kk".dup, &b)
end

class E < StandardError
  def initialize(m, *rest) = (super(m); @rest = rest)
  def rest = @rest
end

class P2
  def initialize(r, t = nil) = (@r = r; @t = t)
  def to_s = "P2(#{@r},#{@t.inspect})"
end

REG = { c: C, kb: KB }

# a splat into the rest: a constant, a Class value, a boxed receiver
def splat(*a) = C.new(*a)
def value(n, *a) = REG[n].new(*a)
def boxed(n, *a) = REG.fetch(n).new(*a)
puts splat(1, "a".dup, "b".dup)
puts value(:c, 1, "a".dup)
puts boxed(:c, 2, "b".dup)
puts C.send(:new, *[3, "s".dup])
puts C.public_send(:new, *[4, "p".dup])

# beside other arguments: copied, gathered, ahead of a post
def lead(*a) = C.new(1, *a)
def trail(*a) = C.new(*a, "t".dup)
def vtrail(n, *a) = REG[n].new(*a, "z".dup)
def post(*a) = PO.new(*a, "z".dup)
puts lead("x".dup, "y".dup)
puts trail(1, "u".dup)
puts vtrail(:c, 1, "v".dup)
puts post(1, "m".dup, "n".dup)

# converted from a typed array, and empty
strs = ["p".dup, "q".dup]
puts C.new(5, *strs)
puts C.new(6, *[1, 2])
puts C.new(7)

# with a keyword, a literal block, both, through super
def kw(*a) = KB.new(*a, k: "x".dup)
def blk(*a) = KB.new(*a) { |v| [v, "b".dup] }
def kwblk(n, *a) = REG[n].new(*a, k: 5) { |v| v.to_s * 2 }
puts kw(1, "a".dup)
puts blk(2, "b".dup)
puts kwblk(:kb, 3, "c".dup)
puts KB.new(4, "d".dup) { |v| "no splat #{v}" }
puts Sub.new(5, "e".dup) { |v| [v] }

# a proc made at the call into an initialize that calls it
puts PB.new("r".dup * 2, &-> { ["l".dup * 2] })
puts PB.new("s".dup) { "blk".dup * 2 }

# an exception class
e = E.new("msg".dup, *["a".dup, 1])
p e.message, e.rest
begin
  raise E.new("m".dup, *["b".dup])
rescue E => x
  p x.rest
end

# a block argument converted into a new proc: a Method, a Symbol; a Proc
# local passes as it is
def mk(x) = x * 2
class SB
  def initialize(r, &b) = (@r = r; @b = b)
  def go = @b.call(3)
end
m = method(:mk)
p SB.new("x".dup * 2, &m).go
p SB.new("y".dup * 2, &:to_s).go
pr = proc { |v| [v] }
p SB.new("z".dup * 2, &pr).go

# a method that captures its rest: a lambda, a Thread, through a receiver,
# a receiver known only at run time, a bare super
def cap(*r) = (l = -> { r }; l.call)
def thr(*r) = Thread.new { r }.value
class Q
  def cap(*r) = (l = -> { r }; l.call)
end
class Q2 < Q
  def cap(*r) = super
end
p cap(*strs)
p cap("a".dup * 2, "b".dup * 2)
p thr(*strs)
p Q.new.cap(*strs)
p [Q.new, Q2.new][ARGV.size].cap(*strs)
p Q2.new.cap(*strs)

# a receiver read out of a container, a String Range argument
PS = [P2, P2]
puts PS.fetch(0).new("a".dup.."c".dup)
puts PS.fetch(1).new("b".dup.."d".dup, "t#{1}")

# many, kept until the end
arr = (1..40).map { |i| KB.new(i, *[i.to_s, "q#{i}"]) { |v| [v, i.to_s] } }
GC.start
puts arr.last
