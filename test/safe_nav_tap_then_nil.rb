# spinel: share
# `v&.then { }` (and tap, yield_self) on a receiver that may be nil skips the
# block when it is nil, as CRuby's &. does. On an Integer, Float, String,
# Array or object that can hold its own nil, the block was inlined ahead of
# the guard and ran on the nil.
def f(v) = v&.then { _1 * 2 }
p f(nil), f(3)
def t(v) = v&.tap { p _1 }
t(nil)
t(3)
def y(v) = v&.yield_self { |q| q + 1 }
p y(nil), y(1)
def g(s) = s&.then { _1.upcase }
p g(nil), g("ab")
def d(v) = v&.then { _1 * 2 } || 0
p d(nil), d(4)
def fl(v) = v&.then { _1 * 2.5 }
p fl(nil), fl(2.0)
def h(a) = a&.then { _1.sum }
p h(nil), h([1, 2])
class P
  def initialize(n) = @n = n
  def n = @n
end
def k(o) = o&.then { _1.n * 2 }
p k(nil), k(P.new(4))
x = nil
p x&.then { _1 * 2 }
p 5.then { _1 + 1 }, [1].tap { _1 << 2 }
def sc(v) = v&.succ
p sc(nil), sc(3)
b = [nil, 3]
p b[0]&.then { _1 * 2 }, b[1]&.then { _1 * 2 }
# the other block emitters, on the same nil-able receivers
def ewi(v) = v&.each_with_index&.to_a
p ewi(nil), ewi([5])
def gs(s) = s&.gsub(/a/) { "A" }
p gs(nil), gs("aba")
def tm(v) = (x = v&.times { print _1 }; x)
p tm(nil)
p tm(2)
def ut(v)
  r = v&.upto(3) { print _1 }
  r
end
p ut(nil)
p ut(1)
def sc2(s) = (r = s&.scan(/\d/) { print _1 }; r)
p sc2(nil)
p sc2("a1")
def lz(v) = v&.lazy&.map { _1 * 2 }&.first(2)
p lz([1, 2, 3])
def sb(v) = v&.sort_by { -_1 }
p sb(nil), sb([1, 3, 2])
