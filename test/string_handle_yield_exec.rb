# A String variable handed to a block through `yield`, `instance_exec`,
# `instance_eval` or a yielding `initialize` is the caller's own String, as
# in CRuby: an append through the block's parameter reaches the caller
# (#6179).
# spinel: gc-minor
def grow(v) = (v << "x"; nil)
def mark(q) = (q << "p"; nil)
def g(t) = (t << "!")

# a method that keeps its block: the yield calls it as a proc
def kept(x, &b)
  @kept = b
  yield x
end
def kept_local(&b)
  @kept = b
  v = +"v"
  yield v
  yield v
  v
end
def walk(n, x, &b)
  return yield(x) if n == 0
  walk(n - 1, x, &b)
end

s = +"a"
100.times { kept(s) { |t| t << "!" } }
@kept.call(s)
p s.size
p kept_local { |t| t << "k" }
w = +"w"
walk(3, w) { |t| t << "!" }
p w

# a spliced yield of a String that is the shared handle
def run(x) = yield(x)
def run_marked(x) = (method(:mark).call(x); yield(x))
h = +"h"
method(:mark).call(h)
run(h) { |t| t << "!" }
p h
m = +"m"
run_marked(m) { |t| t << "!" }
p m
r = run(h) { |t| t.replace("zz") }
p h, r
r = run(h) { |t| t.upcase }
p h, r

# a method's parameter lent through a spliced yield, an instance_exec or a
# yielding initialize
def outer(y) = run(y) { |t| t << "!" }
def own(y) = (run(y) { |t| grow(t) }; y)
o = +"o"
outer(o)
p own(o), o

class Box
  attr_reader :n
  def initialize(x)
    @n = x.size
    yield x
  end
end
def build(y) = Box.new(y) { |t| t << "!" }
b = +"b"
Box.new(b) { |t| t << "!" }
build(b)
Box.new(b, &method(:g))
p b

class Tag
  def initialize(x)
    x << "?"
    yield x
  end
end
tg = +"t"
Tag.new(tg) { |t| t << "!" }
Tag.new(tg) { |t| t.size }
p tg

class Obj
  def initialize = (@v = 1)
end
def exec_in(y) = Obj.new.instance_exec(y) { |t| t << "?" }
e = +"e"
Obj.new.instance_exec(e) { |t| t << "!" }
Object.new.instance_exec(e, 2) { |t, n| t << "!" * n }
nil.instance_exec(e) { |t| grow(t) }
exec_in(e)
q = +"q"
n = Obj.new.instance_exec(q) { |t| t.size + @v }
p e, q, n
i = +"i"
i.instance_eval { |t| t << "!" }
def eval_in(y) = y.instance_eval { |t| t << "?" }
def exec_int(y) = 5.instance_exec(y) { |t| t << "5" }
eval_in(i)
exec_int(i)
p i

class Kls; end
module Mod; end
def class_in(y) = Kls.class_exec(y) { |t| t << "." }
k = +"k"
Kls.class_exec(k) { |t| t << "!" }
class_in(k)
j = +"j"
Mod.module_exec(j) { |t| grow(t) }
p k, j

# a parameter a lambda captures, in a method spliced into its call site
def captured(s)
  f = -> { s << "L" }
  yield s
  f.call
  s
end
c = +"c"
p captured(c) { |t| t << "!" }, c

# a proc handed to a spliced yield
pr = proc { |t| t << "?" }
f = +"f"
run(f, &method(:g))
run(f, &pr)
p f

# a bare call inside a class reaches the class's yielding method, beside a
# top-level one of the name
class Clash
  def run(x) = yield(x)
  def go(v) = run(v) { |t| t << "!" }
end
cl = +"cl"
Clash.new.go(cl)
p cl

# a method passed as `&method(:m)` takes its parameters' types from where
# the block is called: `b.call`, a method handing `&b` on, a `...` forwarder
def gsz(t) = t.size
def krun(x, &b) = b.call(x)
def kfwd(x, &b) = krun(x, &b)
def kall(...) = run(...)
p krun("abc", &method(:gsz)), kfwd("abcd", &method(:gsz)), kall("ab", &method(:gsz))

# frozen, and bytes
fz = "fz".freeze
begin
  kept(fz) { |t| t << "x" }
rescue FrozenError
  p :kept
end
begin
  Obj.new.instance_exec(fz) { |t| t << "x" }
rescue FrozenError
  p :exec
end
bin = +"a\0b"
method(:mark).call(bin)
run(bin) { |t| t << "\0" }
p bin.bytes
