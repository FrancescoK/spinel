# A parameter default that reads an ivar, in a method a program adds to
# Random, Array or Hash: an omitted argument takes the receiver's own ivar
# -- nil until it is set -- through a splat, a keyword hash and a block
# argument too. The default used to name the caller's `self`, which at the
# top level is no variable, and the C did not compile. (The call-binding
# probe's CB10 cases.)

class Random
  def set(v) = (@x = v)
  def pick(a = @x) = a
  def pick_rest(a = @x, *rest) = [a, rest]
  def pick_blk(p1 = @x, *r, &b) = [p1, r, (b ? b.call : nil)]
  def pick_kw(p1, p2, p3 = @x, *r, **nil, &b) = [p1, p2, p3, r]
end

class Array
  def pick(a = @x) = a
  def mark(v) = (@x = v)
  def pick_req(p1, p2, p3 = @x, p4 = @x, k1:, &b) = [p1, p2, p3, p4, k1, (b ? b.call : nil)]
  def pick_kws(k1: @x, k2: @x, **kw) = [k1, k2, kw]
end

class Hash
  def pick(a = @x) = a
  def mark(v) = (@x = v)
end

p Random.new(1).pick
r = Random.new(1)
r.set(7)
p r.pick, r.pick(8)
args = [1]
p Random.new(1).pick_rest(*args), r.pick_rest
blk = proc { :blk }
p r.pick_blk(&blk), r.pick_blk("s1", *[2], 3, &blk)
h = { "s" => 4 }
p((r.pick_kw(1, 2, **h, z: 3) rescue "#{$!.class}: #{$!.message}"))

p [].pick
a = [1, 2]
a.mark(:m)
p a.pick, a.pick(0)
e = []
p a.pick_req(1, *e, 2, k1: 3, &blk)
zh = {z: 3}
p a.pick_kws(*[], **zh, y: 2)

hh = {k: 1}
p hh.pick
hh.mark("h")
p hh.pick
