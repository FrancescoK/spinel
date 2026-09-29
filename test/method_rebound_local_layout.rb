# A Method local written with different targets (`q = C.new.method(:m)`,
# then `q = method(:m)`) is called at run time, through the Method's
# trampoline, and its arguments are bound to every target it may hold. A
# call on it that passed more than plain positionals went over the fixed
# casts one C argument per site argument: a splat became one argument (a
# post after it did not compile), keywords a trailing positional (`**nil`
# never refused them), and the block was dropped. It is laid out as written
# and bound by the target's parameters; a trailing Hash passed as a
# positional binds as one, and a call that raises leaves neither its
# keyword flag nor its block behind. `.to_proc.call` through such a local
# typed the targets' parameters from nothing, Integer, and a String
# argument raised TypeError. A Method read out of a poly slot goes through
# the same lane.

def lg(v) = (puts "arg #{v.inspect}"; v)

class C
  def m(*r, p1) = [:c, r, p1]
  def o(p1 = 51) = [:c, p1]
  def t(p1, p2) = [:c, p1, p2]
  def n(*r, **nil) = [:c, r]
  def b(p0, k1: 70, &b) = [:c, p0, k1, (b ? b.call(p0) : nil)]
  def k(a, b = 2, *r, c, d:, e: 5, **o) = [:c, a, b, r, c, d, e, o]
  def s(p1) = [:c, p1]
  def kk(a = 0, k: 0) = [:c, a, k]
  def boom(a, k: 1) = raise("boom #{a} #{k}")
end
def m(*r, p1) = [r, p1]
def o(p1 = 51) = [p1]
def t(p1, p2) = [p1, p2]
def n(*r, **nil) = [r]
def b(p0, k1: 70, &b) = [p0, k1, (b ? b.call(p0) : nil)]
def k(a, b = 2, *r, c, d:, e: 5, **o) = [a, b, r, c, d, e, o]
def s(p1) = [p1]
def kk(a = 0, k: 0) = [a, k]
def boom(a, k: 1) = raise("top #{a} #{k}")

def try = (yield rescue $!)

# a splat ahead of a post, a trailing splat, a splat beside a `**`
s = [1]
q = C.new.method(:m)
p q.call(*s, 2)
p q.call(*lg(s), lg(2))
p q.call(*s, **{ z: 2 })
q = method(:m)
p q.call(*s, 2)
p q.call(*s, **{ z: 2 })
sh = [{ v: 1 }]
se = []
x = C.new.method(:o)
p x.call(*sh)
p x.call(*se)
p x.call
x = method(:o)
p x.call(*sh)
p x.call

# a String-keyed `**` is a positional hash for a target without keywords
s2 = [1, 2]
y = C.new.method(:t)
p try { y.call(*s2, **{ "s" => 3 }) }
p try { y.call(*s2, 3) }
y = method(:t)
p try { y.call(*s2, **{ "s" => 3 }) }

# `**nil` refuses keywords, literal or splatted
h = { z: 1 }
w = C.new.method(:n)
p try { w.call(**h) }
p try { w.call(1, z: 1) }
p w.call(*s2)
p w.call(**{})
w = method(:n)
p try { w.call(**h) }
p try { w.call(1, z: 1) }

# the block: a literal, a Proc and a Symbol with `&`, and none
pr = proc { |v| [:pr, v] }
v = C.new.method(:b)
p v.call(0) { |i| [:blk, i] }
p v.call(0, k1: 1, &pr)
p v.call(0, **{ k1: 2 }, &:to_s)
p v.call(0)
v = method(:b)
p v.call(0) { |i| [:blk, i] }
p v.call(0, k1: 1, &pr)
p v.call(0)

# a block to a target without `&b` is not left for the next proc
lk = proc { |&bk| bk ? :leak : :none }
u = C.new.method(:t)
p u.call(1, 2) { :x }
p lk.call
u = method(:t)
p u.call(1, 2) { :x }
p lk.call

# a trailing Hash passed as a positional is not keywords, and a call that
# raised leaves neither its keyword flag nor its block to the next call
hk = { k: 5 }
kw = C.new.method(:kk)
p kw.call(hk)
w = C.new.method(:n)
p try { w.call(1, z: 1) }
p kw.call(hk)
bm = C.new.method(:boom)
p try { bm.call(1, k: 2) { :x } }
p lk.call
p kw.call(hk)
kw = method(:kk)
bm = method(:boom)
p kw.call(hk)
p try { bm.call(1, k: 3) { :x } }
p lk.call
p kw.call(hk)

# optionals, a rest and a post, required and optional keywords, a `**`
s34 = [3, 4]
z = C.new.method(:k)
p z.call(1, *s34, 9, d: 7, z: 8)
p z.call(1, 9, **{ d: 0 })
p try { z.call(1, 9) }
p try { z.call(1, d: 1) }
z = method(:k)
p z.call(1, *s34, 9, d: 7, z: 8)
p z.call(1, 9, **{ d: 0 })
p try { z.call(1, 9) }

# `.to_proc.call` through the rebound local binds every target
sp = ["s2"]
r = C.new.method(:s)
p r.to_proc.call("s1")
p r.to_proc.call(*sp)
r = method(:s)
p r.to_proc.call("s1")
p r.to_proc.call(1.5)

# in a method body
def inner(a)
  f = C.new.method(:m)
  g = [f.call(*a, 3)]
  f = method(:m)
  g << f.call(*a, 3) << f.call(3)
  g
end
p inner([1, 2])

# a Method read out of a poly slot
[C.new.method(:n), method(:n)].each { |e| p try { e.call(**{ z: 1 }) } }
[C.new.method(:m), method(:m)].each { |e| p e.call(*s, 2) }
