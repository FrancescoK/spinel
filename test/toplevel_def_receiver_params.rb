# A top-level def that runs on another receiver takes the arguments of every
# call that reaches it: a bare call in a class's method, a send, a Method's
# call and a call from the top level each widen its parameters.
def twice(v) = self.class.name * 0 + v.to_s * 2
def setx(v) = (@x = v)
def getx = @x
def incx = (@x = (@x || 0) + 1)
def idv(v) = [self.class, v]
def idk(v, k: 0) = [self.class, v, k]
def cat(v) = self.class.name + v.to_s
def kv(a, b = a, *r, k: nil, **o) = [self.class, a, b, r, k, o]
def each2(v) = [self.class, v, yield(v)]
def blk(v, &b) = [self.class, b.call(v)]
class A
  def go = twice(7)
  def sx = [setx(1), getx]
  def ix = [setx(1), incx]
  def id = idv(1)
  def ik = idk(1, k: 2)
  def self.cm = idk(3)
  def ct = cat(1.5)
  def k1 = kv(1, k: :x)
  def self.k2 = kv("s", 2, 3, z: 1)
  def e1 = each2(1) { |x| x.to_s * 2 }
  def b1 = blk(:s, &:to_s)
  def s1 = send(:idv, 2.5)
end
class B; def sx = [setx("b"), getx]; end
module M; def self.mm = kv(:m); end
puts twice("ab")
puts A.new.go
p A.new.sx
p B.new.sx
p A.new.ix
setx(:main)
p getx
p A.new.id
p idv(:s)
p idv(2.5)
p A.new.method(:idv).call(:z)
p A.new.s1
p 5.send(:idv, 1)
p nil.send(:idv, "x")
p idk(:s, k: :t)
p A.new.ik
p A.cm
p cat("s")
p A.new.ct
p A.new.k1
p A.k2
p M.mm
p kv(2.5, nil, k: "k")
p A.new.e1
p A.new.b1
p each2("ab") { |x| x * 2 }
p blk(3) { |x| x + 1 }
# a send on a receiver of each kind, a boxed one among them
S = Struct.new(:a)
p A.send(:idv, 1)
p true.send(:idv, "t")
p (1..2).send(:idv, 2.5)
p [1].send(:idv, nil)
p({a: 1}.send(:idv, [1]))
x = ARGV.empty? ? A.new : 3
p x.send(:idv, {k: 1})
p "s".send(:idv, :q)
p S.new(1).send(:idv, A)
p A.new.method(:idv).call(1..3)
# a send on a boxed receiver one of whose classes has its own method of the name: the def's parameters take the
# arguments of the sends that fall back to it
def pt(v, k: 1) = [self.class, v, k]
class PA; def pt(v, k: 0) = [:pa, v, k]; end
class PB; end
[PA.new, PB.new, nil, 3].each { |o| p o.send(:pt, 7, k: 2.5) }
p pt(:s, k: "z")
def ps(v) = (@psv = v; self)
class PA; def ps(v) = :own; end
class PB; attr_reader :psv; end
[PA.new, PB.new].each { |o| r = o.send(:ps, 7); p [r.class, (r.psv rescue nil)] }
ps(:m)
# a yielding def sent a block keeps the dispatch where the receiver's class owns the name
def py(v) = [self.class, v, yield]
class PA; def py(v) = [:pa, v, yield]; end
p [PA.new].map { |o| o.send(:py, 7) { 1 } }
p py(:s) { 2 }
