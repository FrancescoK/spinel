# A lone Array auto-splats into a block only when the call passed no
# keywords: a yield's `**h`, empty or not, into a block taking keywords (or
# any shape but only leading requireds) keeps it whole, and so does a proc
# called so. instance_exec is a method, which drops an empty `**h` before
# it yields. The auto-splat bound the Array's elements into a block with
# keywords (and typed them so), and a proc auto-splatted past an empty
# `**`. A proc's prologue took its posts from the end of the arguments,
# where a yield's block takes them after the optionals, and a boxed or
# splatted value auto-splatted into a block bound only its requireds.
# spinel: gc-minor
h = { z: 2 }
e = {}
x = [[1, 2, 3], 4][0]
w = [[[1, 2]], 4][0]

# yield, keywords beside a lone Array
def y1(h) = yield([1], **h)
p(y1(h) { |*r, p1, **kw| [r, p1, kw] })
p(y1(h) { |a, b, **kw| [a, b, kw] })
p(y1(e) { |a, b, **kw| [a, b, kw] })
p(y1(e) { |a, b, k: 0| [a, b, k] })
p(y1(e) { |a, b = 5, **kw| [a, b, kw] })
p(y1(e) { |a, b, **nil| [a, b] })
p(y1(e) { |a, *r| [a, r] })
p(y1(e) { |a, b| [a, b] })
p(y1(e) { |a, | a })
def y2 = yield([1, 2], z: 3)
p(y2 { |a = 5, b, **kw| [a, b, kw] })
p(y2 { |a, b| [a, b] })
def y3 = yield([1, 2], **{})
p(y3 { |a, *r, **kw| [a, r, kw] })
def y4(a) = yield(*a, z: 3)
p(y4([[1, 2]]) { |a, b, **kw| [a, b, kw] })
def y5 = yield(*[[1, 2]], **{})
p(y5 { |*r, p1, **kw| [r, p1, kw] })
p(y5 { |a, b| [a, b] })
def y6 = yield([1, 2])
p(y6 { |a, b, **kw| [a, b, kw] })

# yield, a splat or a boxed value spread by the distribution
def s1 = yield(*[1, 2])
def s2 = yield(*[1])
p(s2 { |p1, p2 = "d2"| [p1, p2] })
def b1(x) = yield(x)
p(b1(x) { |a, b = 5, c| [a, b, c] })
p(b1(x) { |a, *r, c| [a, r, c] })
p(b1(x) { |a = 5, b| [a, b] })
p(b1(4) { |a = 5, b| [a, b] })
def b2(x) = yield(*x)
p(b2(x) { |a, b = 5| [a, b] })
p(b2(x) { |a = 5, b| [a, b] })
p(b2(w) { |a, b = 5, c| [a, b, c] })

# a proc: through `&`, and .call
blk = proc { |*r, p1, **kw| [r, p1, kw] }
p(y1(h, &blk))
p(y1(e, &blk))
blk = proc { |a, b, **kw| [a, b, kw] }
p(y1(h, &blk))
p(y3(&blk))
p(y6(&blk))
f = proc { |a, b| [a, b] }
p(f.call([1, 2], **e))
p(f.call([1, 2], **h))
f = proc { |a, *r| [a, r] }
p(f.call([1, 2], **e))
f = proc { |a, b, k: 0| [a, b, k] }
p(f.call([1, 2], **e))
p(f.call([1, 2]))
f = proc { |a = 5, b, **kw| [a, b, kw] }
p(f.call([1, 2], z: 3))

# a proc's posts come after the optionals
p(proc { |p1, p2 = 52, p3| [p1, p2, p3] }.call(1, 2, 3, 4))
p(proc { |a = 5, b| [a, b] }.call(1, "s", :t))
p(proc { |a, *r, b, c| [a, r, b, c] }.call(1, 2))
p(proc { |a, b = 7, *r, c| [a, b, r, c] }.call(1, 2))
p(proc { |a, b = 7, *r, c| [a, b, r, c] }.call(1, 2, 3, 4, 5))
p(proc { |a = 1, b = 2, c, d| [a, b, c, d] }.call([:x, :y, :z, :w, :v]))
p(proc { |a = 1, b = 2, c, d| [a, b, c, d] }.call(:x))
p(proc { |a, b = 5, c, k: 0| [a, b, c, k] }.call(*[1, 2, 3, 4, 5]))
p(proc { |a = 5, b, **kw| [a, b, kw] }.call(1, 2, 3))
g = proc { |a, b = 5, c| [a, b, c] }
p(y2(&g))
p(s1(&g))
p(->(a, b = 5, c) { [a, b, c] }.call(1, 2))
class DM
  define_method(:m) { |a, b = 5, *r, c| [a, b, r, c] }
end
p(DM.new.m(1, 2))
p(DM.new.m(1, 2, 3, 4))

# instance_exec
o = Object.new
p(o.instance_exec([1, 2, 3]) { |a, b = 5, c| [a, b, c] })
p(o.instance_exec([1, 2, 3]) { |a, *r| [a, r] })
p(o.instance_exec([1, 2], **e) { |a, b, **kw| [a, b, kw] })
p(o.instance_exec([1, 2], **e) { |a, *r| [a, r] })
p(o.instance_exec([1, 2], z: 3) { |a, b, **kw| [a, b, kw] })
p(o.instance_exec([1, 2]) { |a, b, **kw| [a, b, kw] })
p(o.instance_exec(x) { |a = 5, b| [a, b] })
p(o.instance_exec(*[[1, 2]]) { |a, b = 5, c| [a, b, c] })
