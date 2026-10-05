# Flag-only: without the flag (as on master) each call answers a copy, and the appends are lost.
# A call that answers a String the rule shares hands that String over:
# into a caller's Array, a local, a parameter. A call answering a String of
# its own (a builtin's, a fresh concatenation) does not, and nil stays nil.
class K
  attr_reader :n
  def initialize; @n = +"n"; @m = +"m"; end
  def keep(a) = (a << n)
  def give = n
  def pick(c) = (c ? n : n + "?")
end
class L < K
  def n = "over"
end
k = K.new; a = []; k.keep(a); a[0] << "!"; p k.n, a
g = k.give; g << "#"; p k.n
x = k.pick(true); x << "1"; y = k.pick(false); y << "2"; p k.n, y
l = L.new; b = []; l.keep(b); p b, l.n
for o in [K.new, L.new]
  r = o.give
  r << "%" unless r.frozen?
  p o.n
end
def f(x) = x + "!"
def h(x) = (x.empty? ? nil : x)
def base(x) = File.basename(x)
s = +"/a/b"; s << "c"
p [f(s)], [h(+""), h(s)], [base(s)], s
# a class method answering a class variable
class C
  @@v = +"v"
  def self.add(x) = @@v << x
  def self.v = @@v
end
w = C.v
C.add("4")
p w
