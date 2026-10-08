# The inference fixpoint has a 128-round cap. Reaching it is not a slow path,
# it is a non-answer: the loop stops because the cap says so, mid-oscillation,
# and where it stops decides which of two typings gets emitted. Both typings
# usually pass the test -- a boxed slot prints the same answer as a typed one --
# so nothing else in the suite can see it. (#4116)
#
# `require "pathname"` alone used to reach the cap, twice, and cost a 53k-line
# tree 124.6s in the front end against 11.5s converged.
require "pathname"

# A few shapes that were capped for their own reasons: IO.pipe's two targets,
# a case/in binding, and a File.open block parameter.
r, w = IO.pipe
w.write("x")
w.close
puts r.read

case [1, "a"]
in [Integer => n, String => s]
  puts "#{n}#{s}"
end

p Pathname.new(".").directory?

# An empty `{}` the caller then writes into, handed to a parameter that is
# poly (a second call site passes another hash kind). The reverse binding
# widened the local to the PolyPoly hash (#3158); its own element writes
# re-derived the StrStr kind every round; to the cap, every compile.
def store(h, n)
  h[n] ||= n * 10
end
sub = {}
sub["body"] = "hi"
store(sub, 1)
store({ 2 => 3 }, 2)
p sub

# Four more shapes, each to the cap for its own reason (#4962).
#
# A table the object-array narrowing withdrew: `fc_pair`'s value narrowed to
# an int-array table before `FcBox.new(qr[0])` had widened the ivar, and the
# decision it then withdrew came back every round as a pin.
def fc_pair(a) = [a, []]
class FcBox
  attr_reader :v
  def initialize(v) = @v = v
end
fb = FcBox.new([1, 2])
qr = fc_pair(fb.v)
fb = FcBox.new(qr[0])
p fb.v

# A string range's block-driven step, lowered to `step(n).each { }` and folded
# straight back by the Enumerator#each rule.
fs = []
("a".."e").step(2) { |s| fs << s }
p fs

# Two procs of different return types in one local: each write reported
# a change of the local's proc return type.
fsh = ->(x) { x }
fsh = ->(a, b, c) { a + b + c }
p fsh.curry(3).call(1).call(2).call(3)

# A parameter widened by a push, bound from an int-array ivar: the two-kinds
# rule and the push rule answered it in turn.
module FcHeld
  def self.add(into) = into.push("pushed")
end
class FcNamed
  def initialize = @a = [0]
  def go = FcHeld.add(@a)
  def out = @a
end
fn = FcNamed.new
fn.go
p fn.out

# A *rest parameter the body reassigns from itself (`args = args.first`, the
# background job's perform(*args)), as a statement of the body and inside a
# branch: the desugared copy must not keep the fold alternating (#6491)
def fp_perform(*args)
  args = args.first
  args
end
def fp_maybe_first(*a)
  if a.size > 0
    a = a.first
  end
  a
end
p fp_perform(7), fp_maybe_first(7), fp_maybe_first

# A Hash parameter its body reassigns from a boxed value and then writes
# String keys into (ActionView's `html_options = (html_options || {})
# .stringify_keys; html_options["href"] = ...`): the String-keyed writes
# narrowed the poly parameter to the StrStr hash, and the body's own write
# widened it back to poly, every round. A multiple assignment the same.
def fp_norm(h)
  return h if h.is_a?(Hash)
  "x"
end
def fp_link(addr, opts = {})
  opts = fp_norm(opts)
  opts["href"] = "mailto:#{addr}"
  opts
end
def fp_link2(addr, opts = {})
  opts, n = fp_norm(opts), 1
  opts["href"] = "tel:#{addr}#{n}"
  opts
end
p fp_link("a@b"), fp_link2("5")
