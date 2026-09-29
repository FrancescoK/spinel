# A block bound by a yield, a proc's prologue and instance_exec's literal
# block all follow CRuby's proc distribution: requireds (leading and post)
# first, optionals from what remains, a rest the middle, extras dropped but
# run, missing positions nil or their default, a count known only at run
# time (a splat, a `**` that may be empty) gathered, every value run in
# source order (a `**` operand, a value's own setup, and a read a later
# value or a default can change among them), and a lone Array auto-splatted
# when the block takes a required or two optionals and more than one
# positional or a rest. instance_exec kept a copy of its own that never took
# a post or a splat; the yield bound a lone untyped splat node as a value,
# and a value's setup ran ahead of the values before it; the proc prologue
# auto-splatted only for two requireds and refused an optional's default
# that reads another parameter.

def lit(x) = (print x, " "; x)
def lh(h) = (print "h "; h)

# yield
def y_splat_empty = yield(*[])
p(y_splat_empty { |p1 = 51| [p1] })
def y_empty_lit = yield([])
p(y_empty_lit { |x| x })
def y_splat_nil = yield(*nil)
p(y_splat_nil { |a = 3, b = 4| [a, b] })
def y_extra = yield(lit(1))
begin; y_extra { |k1:| [k1] }; rescue => e; puts e.message; end
def y_mid_default = yield(1, lit(2))
p(y_mid_default { |a, b = lit(9), c| [a, b, c] })
def y_extras = yield(lit(1), lit(2), lit(3), lit(4))
p(y_extras { |a, b = 0, c| [a, b, c] })
def y_pair = yield([1, 2])
p(y_pair { |a = 1, *r| [a, r] })
p(y_pair { |*r, a| [r, a] })
p(y_pair { |a, k: 5| [a, k] })
def y_nokw(h) = yield(**h)
begin; p(y_nokw({ z: 1 }) { |**nil| 1 }); rescue => e; puts e.message; end
p(y_nokw({}) { |**nil| 1 })
def y_str_key(h) = yield("s" => 1, **h)
p(y_str_key({ z: 2 }) { || [] })
def y_first(h) = yield(lit(1), **lh(h))
p(y_first({ k1: 2 }) { |a, k1:| [a, k1] })
def y_setup = yield(lit(1), [lit(2), lit(3)].map { |v| v * 2 })
p(y_setup { |a, b| [a, b] })
class Rd
  def initialize = (@v = 1)
  def change = (@v = 2; { z: 0 })
  def y_read = yield(@v, **change)
  def y_kw = yield(k: @v)
  def run = [y_read { |a, **kw| [a, kw] }, y_kw { |a = (@v = 9), k: 0| [a, k] },
             instance_exec(@v, **change) { |a, **kw| [a, kw] }]
end
p Rd.new.run
def y_local = (z = 1; yield(b: z, a: (z = 2)))
p(y_local { |a:, b:| [a, b] })
def kw_out(a:, b:) = [a, b]
x = 1
p kw_out(b: x, a: (x = 2))
def y_kw_str(h) = yield(k1: 1, **h)
begin; p(y_kw_str({ "s" => 2 }) { |k1: 70| [k1] }); rescue => e; puts e.message; end

# proc and lambda
pr = proc { |k, v = 5| "#{k}=#{v}" }
p pr.call([:a, 1])
f = proc { |a, b = (a * 2), *r, c| [a, b, r, c] }
p f.call(1)
p f.call(1, 2, 3)
p f.call([4])
p proc { |a = 1, *r| [a, r] }.call([1, 2])
p proc { |*r, a| [r, a] }.call([1, 2])
p proc { |p1 = 51, p2 = p1| [p1, p2] }.call
p proc { |p1 = 51, p2 = p1| [p1, p2] }.call("a")
p ->(p1 = 51, p2 = p1) { [p1, p2] }.call
p ->(p1, p2 = p1) { [p1, p2] }.call(1)
p ->(s, t = s + "!") { [s, t] }.call("x")
p [[1], [2, 3]].map { |a, b = a| [a, b] }
e0 = {}
p proc { || [] }.call(z: 1, **e0)
begin; ->() { [] }.call(z: 1, **e0); rescue => e; puts e.message; end

# instance_exec
o = Object.new
p o.instance_exec(1, 2, 3, 4) { |p1, p2, p3 = 53, p4| [p1, p2, p3, p4] }
p o.instance_exec(1, 2, 3) { |p1, p2, *r, p3| [p1, p2, r, p3] }
p o.instance_exec(1) { |*r, p1| [r, p1] }
p o.instance_exec(1, 2) { |*r, a| r }
s = [[1, "b"][0]]
p o.instance_exec(*s) { |p1 = 51| [p1] }
s2 = [1]
p o.instance_exec(*s2) { |p1 = 51| [p1] }
h = { z: 1 }
p o.instance_exec(**h) { |p1 = 51| [p1] }
begin; p o.instance_exec(**h) { |**nil| [] }; rescue => e; puts e.message; end
p o.instance_exec(lit(1)) { || [] }
p o.instance_exec(lit(1), **lh(h)) { |a, z:| [a, z] }
p o.instance_exec(lit(1), lit(2), k: lit(3), **lh(h)) { |a, b = 7, *r, k:, z:| [a, b, r, k, z] }
p o.instance_exec(lit(1), k: [lit(:b)].map { |v| v }) { |a, k:| [a, k] }
p 3.instance_exec(lit(1), **lh(h)) { |a, **kw| [a, kw] }
p o.instance_exec([1, 2]) { |a, b| [a, b] }
p o.instance_exec("x", 2) { |a, b = 3, c| [a, b, c] }
p o.instance_exec(1, k: 2) { |a, k:| [a, k] }
p o.instance_exec(k: 2) { |a = 9, k: 1| [a, k] }
begin; p o.instance_exec(k1: 1, **{ "s" => 2 }) { |k1:| [k1] }; rescue => e; puts e.message; end
p 5.instance_exec(1, 2, 3) { |a, *r, b| [self, a, r, b] }
p nil.instance_exec(4) { |*r, b| [r, b] }
p 3.instance_exec(1, 2) { |*r, a| r }
class K
  def initialize = (@v = 9)
  def run(*a, &b) = instance_exec(*a, &b)
end
p K.new.run(1, 2) { |x, y| [@v, x, y] }
p K.new.run([1, 2]) { |x, y| [@v, x, y] }
