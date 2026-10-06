# A String a call hands to an optional parameter is the caller's String, as
# it is for a required one (#6179): a Method, an UnboundMethod's bind_call,
# a method define_method defines, a kept block, a block a lowered method
# yields to, a proc or lambda literal, and a spliced yield or instance_exec
# into a literal block bind call position k to the optional there whenever
# no required parameter follows it. Each append is 100 bytes, so a copy
# cannot pass by capacity; nil, passed or defaulted, stays nil.
X = "x" * 100
def fill(s = nil) = (s << X if s; nil)
def fill2(a, s = nil, t = nil) = (t << X if t; s << X if s; a)
def dflt(s = +"d") = (s << X; s.size)
def post(a = nil, b) = (b << X; a << X if a; nil)
def rest(a = nil, *r) = (a << X if a; r.size)
def reads(s = nil) = s ? s.size : -1
class C
  def go(s = nil) = (s << X if s; nil)
  define_method(:dm) { |s = nil| s << X if s; nil }
end
class K
  def keep(&b) = (@b = b; self)
  def run(x) = @b.call(x)
  def kept_yield(x, &b) = (@b = b; yield x)
end
def rec(x, n, &b) = n > 0 ? rec(x, n - 1, &b) : yield(x)

s = +"a"; method(:fill).call(s); p s.size
s = +"a"; m = method(:fill); m.(s); m[s]; m === s; p s.size
s = +"a"; method(:fill).to_proc.call(s); p s.size
s = +"a"; fill(s); p s.size
p method(:fill).call, method(:fill).call(nil)
s = +"a"; u = +"u"; p method(:fill2).call(1, s, u), s.size, u.size
s = +"a"; p method(:fill2).call(2, s), s.size
s = +"a"; p method(:dflt).call(s), method(:dflt).call, s.size
s = +"a"; t = +"t"; method(:post).call(s); method(:post).call(t, s); p s.size, t.size
s = +"a"; p method(:rest).call(s, 1, 2), s.size
s = +"a"; p method(:reads).call(s), method(:reads).call, s.size
s = +"a"; C.instance_method(:go).bind_call(C.new, s); p s.size
s = +"a"; C.instance_method(:dm).bind_call(C.new, s); p s.size
s = +"a"; C.new.dm(s); C.new.method(:dm).call(s); p s.size
k = K.new.keep { |t = nil| t << X if t; nil }
s = +"a"; k.run(s); p s.size
s = +"a"; K.new.kept_yield(s) { |t = nil| t << X if t }; p s.size
s = +"a"; rec(s, 2) { |t = nil| t << X if t }; p s.size
pr = proc { |t = nil| t << X if t; t && t.size }
s = +"a"; p pr.call(s), pr.call, pr.call(nil), s.size
la = lambda { |a, t = nil| t << X if t; a }
s = +"a"; p la.call(1, s), la.(2), s.size
pd = proc { |t = (+"d")| t << X; t.size }
s = +"a"; p pd.call(s), pd.call, s.size
def run(x) = yield(x)
def run2(x, &b) = (b.call(x); yield(x))
def run3(a, x) = yield(a, x)
def run6(x) = (y = x; yield y)
s = +"a"; run(s) { |t = nil| t << X if t }; p s.size
s = +"a"; run2(s) { |t = nil| t << X if t }; p s.size
s = +"a"; run3(1, s) { |n, t = nil, *r| t << X if t }; p s.size
s = +"a"; run6(s) { |t = nil| t << X }; p s.size
p run(nil) { |t = nil| t }, run(+"q") { |t = (+"w")| t.size }
s = +"a"; Object.new.instance_exec(s) { |t = nil| t << X if t }; p s.size
sh = ->(u) { u << "P" }
s = +"a"; sh.call(s); run(s) { |t = nil| t << X if t }; p s.size
s = +"a"; sh.call(s); Object.new.instance_exec(s) { |t = nil| t << X }; p s.size
def run4(f) = (z = +"z"; f.call(z); yield(z); yield; z.size)
p run4(sh) { |t = (+"d")| t << X; t.size }
fz = "fr".freeze
begin; method(:fill).call(fz); rescue FrozenError => e; p e.class; end
begin; pr.call(fz); rescue FrozenError => e; p e.class; end
begin; run(fz) { |t = nil| t << X }; rescue FrozenError => e; p e.class; end
