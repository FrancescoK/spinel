# A block's parameters are typed from what its sites bind, by the plan the
# binders follow (block_fill, block_auto_splats): a keyword hash goes to the
# keywords alone, a splat or a `**` that may be empty gathers the values, a
# lone Array auto-splats, and a parameter left without a value is nil. Every
# site counts -- each yield, each `b.call`, each instance_exec forwarding the
# block -- and a proc's `.call` and a literal block's instance_exec follow the
# same plan. Typed by rules of their own, a block keyword took its default's
# type alone (`yield(**h)` into `|k1: 70|` read a Symbol as an Integer), a
# second `b.call` never counted, a nil beside an Integer bound 0, a keyword
# hash typed a positional, a splat's elements were typed by position, and a
# true/false parameter one `.call` left out read the missing value as true.
# Under --int-overflow=promote the last two probes widen their arguments to
# a poly array after inference, and the block parameters follow.

def lit(x) = x

# keywords: from the keyword hash and its `**` operands only
def y_ks(h) = yield(**h)
p(y_ks({ k1: :v1 }) { |k1: 70| k1 })
p(y_ks({}) { |k1: 70| k1 })
def y_kmix = [yield(1, k: "x"), yield(2, **{ k: :s }), yield(3)]
p(y_kmix { |a, k: 7| [a, k] })

# every b.call site counts
def bc(&b) = [b.call(1, "s"), b.call(1), b.call(1, k: "x")]
p(bc { |a, b = 5| [a, b] })
p(bc { |a, b| [a, b] })

# a nil beside an Integer
def y_nil = [yield(nil), yield(1, "s")]
p(y_nil { |a| [a] })

# splats and gathered values
def y_sp = [yield(*[1], "s"), yield(1, *["s", :t]), yield(*[]), yield(1, 2, 3)]
p(y_sp { |a, b = 5| [a, b] })
p(y_sp { |a, *r, z| [a, r, z] })
def y_ds(h) = [yield(1, **h), yield("s", 2)]
p(y_ds({}) { |a, b| [a, b] })
p(y_ds({ k: 1 }) { |a, b| [a, b] })

# a gathered optional keeps its default's type, the values sure or not
def y_opt = yield(*[1, 2])
p(y_opt { |a, b = "d"| [a, b] })

# auto-splat of a lone Array
def y_as = [yield([1, "s"]), yield([2])]
p(y_as { |a, b| [a, b] })
p(y_as { |a| a })

# a post after an optional
def y_post = [yield(5), yield("s", 6)]
p(y_post { |a = 1, c| [a, c] })

# instance_exec, with a literal block and forwarding one
o = Object.new
p(o.instance_exec(1, "s") { |a, b = 5| [a, b] })
p(o.instance_exec([1, 2]) { |a = 4, b = 5| [a, b] })
p(o.instance_exec(**{ k1: :v1 }) { |k1: 70| [k1] })
p(o.instance_exec(1) { |a, *r| [a, r] })
class Fw
  def go(&b) = [instance_exec(1, &b), instance_exec("s", k: 2, &b)]
end
p(Fw.new.go { |a, k: 0| [a, k] })

# a proc's and a lambda's call
pr = proc { |a, b, k: 1| [a, b, k] }
p pr.call(1, k: "x")
p pr.call(*[1], "s")
p pr.call(1, **{})
l = ->(a, b) { [a, b] }
p l.call(*[1, "s"])
pb = proc { |a, b| [a, b] }
p pb.call(true, false), pb.call(true)
pq = proc { |a, b| [a, b] }
p pq.call(:x, :y), pq.call(:z)

# forwarding the method's own parameters: keywords stay keywords only
# through its `**kw`, otherwise the rest collects them as a Hash
def fw_rest(*a, &b) = b.call(*a)
p(fw_rest(1, k: "x") { |x, k: 0| [x, k] })
def fw_kw(*a, **kw, &b) = b.call(*a, **kw)
p(fw_kw(1, k: "x") { |x, k: 0| [x, k] })

# a stored block, run as a proc
class St
  def initialize(&b) = @b = b
  def run = [@b.call(1, "s"), @b.call("t")]
end
p St.new { |a, b| [a, b] }.run

# a value that widens after inference under --int-overflow=promote
def y_arr(a, b) = yield([a, b])
p(y_arr(1, 2) { |x| x })
p(o.instance_exec(1, k: [lit(2)].map { |v| v }) { |a, k:| [a, k] })
