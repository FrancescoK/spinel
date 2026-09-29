# The block a proc's `.call { }` or `.call(&b)` passes belongs to that call:
# a body without a `&b` parameter drops it, so a later `&b` body called
# without one binds nil; an argument that calls a `&b` proc does not take
# the outer call's block; a body reads its own before a default or another
# proc call in it runs; and a call that raised leaves nothing behind for
# the next one. Through `yield`, `map(&pr)`, `instance_exec`,
# `define_method`, `Method#to_proc` and a composed proc the same holds.

blk = proc { :given }
f = proc { |a| a }
g = proc { |a, &b| [a, b ? b.call : nil] }

p f.call(1) { :blk }
p g.call(2)
p f.call(3, &blk)
p g.call(4)
p g.call(5, &blk)
p g.call(6) { :lit }
p g.call(7)

l = ->(a) { a }
p l.call(1) { :blk }
p g.call(8)

leak = -> { f.call(0) { :leaked } }
leak.()
def y = yield(1)
p(y { |a, &b| b })
leak.()
p([1].map { |a, &b| b })
leak.()
p [9].map(&g)
leak.()
p(Object.new.instance_exec(1) { |a, &b| b })
class C
  define_method(:dm) { |a, &b| b }
end
leak.()
p C.new.dm(1)
def mb(a, &b) = b
p mb(0)
leak.()
p method(:mb).to_proc.call(1)
p method(:mb).to_proc.call(1, &blk).equal?(blk)
leak.()
p method(:mb).to_proc.call(2)

# an argument calling a `&b` proc, and a proc called in a `&b` body
p g.call(g.call(10)) { :outer }
p g.call(g.call(11, &blk))
k = proc { |a, &b| [g.call(a), b ? b.call : nil] }
p k.call(12) { :k }
d = proc { |a = g.call(13), &b| [a, b ? b.call : nil] }
p d.call { :d }

# a call that raised
r = proc { |a| raise "no" }
begin
  r.call(1) { :raised }
rescue => e
  p e.message
end
p g.call(14)
lam = ->(a, &b) { b }
begin
  lam.call { :arity }
rescue ArgumentError => e
  p e.message
end
p g.call(15)

# splatted arguments, keywords and a composed proc
s = [16]
p g.call(*s, &blk)
p g.call(*s) { :splat }
p g.call(*s)
kw = proc { |a, k: 0, &b| [a, k, b ? b.call : nil] }
p kw.call(17, k: 1) { :kw }
p kw.call(18, k: 2)
t = proc { |a| a * 10 }
p (t >> g).call(19) { :composed }
p (g << t).call(20) { :composed }
p g.call(21)
