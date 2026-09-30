# A default that is an earlier parameter (`y = x`) is the String the caller
# passed for x: an append through either is the caller's, and the other
# sees it. Each append is 100 bytes, so a copy cannot pass by capacity; a
# default that only starts from x (`x.dup`, `x + ""`) stays a String of its
# own.
X = "!" * 100
def m(x, y = x) = (y << X; nil)
def both(x, y = x) = (y << X; [x.size, y.size])
def first(x, y = x) = (x << X; y.size)
def kw(x, k: x) = (k << X; nil)
def cp(x, y = x.dup) = (y << X; y.size)
def cp2(x, y = x + "") = (y << X; y.size)
def rd(x, y = x) = x.size + y.size
class C
  def initialize(x = +"z", y = x) = (y << X)
  def im(x, y = x) = (y << X; nil)
end
class A; def w(x, y = x) = (y << X; nil); end
class B; def w(x, y = nil) = nil; end

s = +"a"; m(s); p s.size
s = +"a"; m(s, s); p s.size
s = +"a"; p both(s), s.size
s = +"a"; p first(s), s.size
s = +"a"; kw(s); p s.size
s = +"a"; p cp(s), cp2(s), s.size
s = +"a"; p rd(s), s.size
s = +"a"; C.new.im(s); p s.size
s = +"a"; C.new(s); p s.size
s = +"a"; [A.new, B.new].each { |o| o.w(s) }; p s.size
s = +"a"; method(:m).call(s); p s.size
s = +"a"; method(:m).to_proc.call(s); p s.size
s = +"a"; ->(x, y = x) { y << X; nil }.call(s); p s.size
s = +"a"; proc { |x, y = x| y << X; nil }.call(s); p s.size
s = +"a"; ->(x, y = x) { y << X; nil }.call(s, +"b"); p s.size
begin; m("fr".freeze); rescue FrozenError => e; p e.class; end
