# A String a block, a proc or a lambda gathers into its rest parameter is
# the caller's String when the body appends to the rest's element
# (`{ |*q| q[0] << x }`), as a method's gather is (#6179): the variable is
# the shared handle and the Array holds it, through a spliced yield,
# instance_exec, a proc's or lambda's call, a kept block, a lowered yield
# and a proc out of a mixed Array. Each append is 100 bytes, so a copy
# cannot pass by capacity.
X = "x" * 100
sh = ->(u) { u << "P" }
def y2(a, b) = yield(a, b)
def y3(a, b, c) = yield(a, b, c)
def via(x) = y2(x, 1) { |*q| q[0] << X }
s = +"a"; u = +"u"; y2(s, u) { |*q, t| q[0] << X }; p s.size
s = +"a"; y2(s, u) { |*q| q[0] << X }; p s.size
s = +"a"; v = +"v"; y2(s, v) { |*q| q.each { |e| e << X } }; p s.size, v.size
s = +"a"; y3(1, s, u) { |n, *q, t| q.last << X }; p s.size
s = +"a"; sh.call(s); y2(s, 1) { |*q| q[0] << X }; p s.size
s = +"a"; via(s); p s.size
p y2(nil, 1) { |*q| q[0] }
s = +"a"; Object.new.instance_exec(s, 1) { |*q| q[0] << X }; p s.size
pr = proc { |*q| q[0] << X }
s = +"a"; pr.call(s, 1); p s.size
la = ->(*q) { q.first << X }
s = +"a"; la.call(s); la.(s); p s.size
class K
  def keep(&b) = (@b = b; self)
  def run(x) = @b.call(x, 2)
  def kept(x, &b) = (@b = b; yield 1, x)
end
k = K.new.keep { |*q| q[0] << X }
s = +"a"; k.run(s); p s.size
s = +"a"; K.new.kept(s) { |*q| q[1] << X }; p s.size
fs = [proc { |*q| q[0] << X }, 1][ARGV.size]
s = +"a"; fs.call(s); p s.size
rd = proc { |*q| q[0].size }
s = +"a"; p rd.call(s), s.size
fz = "fr".freeze
begin; pr.call(fz); rescue FrozenError => e; p e.class; end
begin; y2(fz, 1) { |*q| q[0] << X }; rescue FrozenError => e; p e.class; end
