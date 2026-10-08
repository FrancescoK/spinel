# What a call's keyword hash is to its callee is decided once, and so is
# when each keyword error is raised. A callee taking keywords never counts
# the hash as a positional, `**` spreads included, so the count comes first;
# one taking none counts a hash with a literal key as one more positional,
# after a splat too; a `**nil` callee refuses a `**` that holds a key. A
# required keyword is missing, and a literal key -- a String as much as a
# Symbol -- is unknown, whatever the rest of the parameter list, and after a
# splat only once the run time has judged the count, and every argument runs
# before a `**` converts or a keyword is judged. A Struct taking keywords
# binds them by name when a splat beside them leaves no positional.
# spinel: gc-minor
def t(l)
  r = yield
  puts "#{l}: #{r.inspect}"
rescue ArgumentError, TypeError => e
  puts "#{l}: #{e.class}: #{e.message}"
end
e = []
h = { z: 1 }
hs = { "s" => 4 }

# a required keyword after a splat, once the count is judged
def k1(k1:) = [k1]
def rk(a, k1:) = [a, k1]
t("empty splat") { k1(*[]) }
t("empty var") { k1(*e) }
t("splat one") { k1(*[1]) }
t("splat fills") { rk(*[1]) }
t("splat short") { rk(*[]) }
t("splat over") { rk(*[1, 2], k1: 1) }
t("splat unknown") { rk(*[1], k1: 1, z: 1) }

# `**` is never a positional for a callee taking keywords
t("nil short") { rk(**nil) }
t("known short") { rk(**{ k1: 5 }) }
t("known over") { rk(1, 2, **{ k1: 5 }) }
t("splat then ds") { rk(*[], **h) }
t("splat ds fills") { rk(*[1], **h) }
t("splat ds over") { rk(*[1, 2], **h) }

# a rest or a **kwrest beside a required keyword still checks it
def rr(*r, k1:) = [r, k1]
def kr(a, k1:, **kw) = [a, k1, kw]
t("rest bare") { rr }
t("rest args") { rr(1, 2) }
t("rest unknown") { rr(z: 1) }
t("rest known unknown") { rr(k1: 1, z: 1) }
t("kwrest short") { kr }
t("kwrest missing") { kr(1) }
t("kwrest splat") { kr(*[1]) }
def ro(p1, *r, k1: 70) = [p1, r, k1]
t("rest opt splat") { ro(*[]) }
t("rest opt splat kw") { ro(*e, k1: 1) }
t("rest opt splat ds") { ro(*[], **hs) }
t("rest req splat") { rr(*[1]) }

# a String key is a keyword like any other
def okk(a, k: 0) = [a, k]
t("string") { okk(1, "s" => 1) }
t("string alone") { okk("s" => 1) }
t("string sym") { okk(1, "s" => 1, z: 2) }
t("string ds") { okk(1, "s" => 1, **h) }
t("string ds empty") { k1(k1: 1, "s" => 2, **{}) }
t("string ds missing") { k1("s" => 2, **h) }
t("ds string key") { k1(k1: 1, **hs) }
t("ds string repeat") { k1(k1: 1, k1: 2, **hs) }
t("ds string only") { k1(**hs) }

# a callee taking no keywords counts a literal-keyed hash
def ok(a) = a
def none = 1
t("hash over") { ok(1, "s" => 1) }
t("hash fills") { ok("s" => 1) }
t("splat hash") { ok(*[], "s" => 1) }
t("splat hash over") { ok(*[1], "s" => 1) }
t("none splat kw") { none(*[], z: 1) }
t("none splat str") { none(*[], "s" => 1) }
t("none str ds") { none("s" => 1, **h) }
t("none splat") { none(*[1]) }
t("none empty ds") { none(*[], **{}) }
t("past params") { ok(1, *[2]) }
t("past empty") { ok(1, *e) }

# a `**nil` callee refuses a `**` holding a key
def nk(*r, **nil) = r
def nk1(a, **nil) = a
t("nokw ds") { nk(**{ z: 1 }) }
t("nokw ds args") { nk(1, **h) }
t("nokw empty") { nk(**{}) }
t("nokw short") { nk1(**{}) }
t("nokw ds short") { nk1(**h) }

# the dispatch, a class method, send and an inlined yielding method
class O
  def rk(a, k1:) = [a, k1]
  def k1(k1:) = [k1]
  def ok(a) = a
  def self.rk(a, k1:) = [a, k1]
end
o = O.new
t("obj splat") { o.k1(*[]) }
t("obj ds short") { o.rk(**{ k1: 5 }) }
t("obj splat ds") { o.rk(*[], **h) }
t("obj string") { o.k1(k1: 1, "s" => 2) }
t("obj ds string") { o.k1(k1: 1, **hs) }
t("obj past") { o.ok(1, *[2]) }
class O
  def rr(p1, *r, k1:) = [p1, r, k1]
  def ro(p1, *r, k1: 70) = [p1, r, k1]
end
t("obj rest short") { o.rr }
t("obj rest missing") { o.rr(1) }
t("obj rest opt short") { o.ro }
t("cls ds short") { O.rk(**{ k1: 5 }) }
t("cls splat") { O.rk(*[1]) }
t("send splat") { send(:k1, *[]) }
def y(a, k1:) = yield(a, k1)
t("yield splat ds") { y(*[], **h) { |a, b| [a, b] } }
t("yield ds short") { y(**{ k1: 5 }) { |a, b| [a, b] } }
t("yield string") { y(1, "s" => 2, k1: 3) { |a, b| [a, b] } }
t("yield splat") { y(*[1]) { |a, b| [a, b] } }

# a Struct taking keywords, beside a splat that leaves no positional
S = Struct.new(:k1, keyword_init: true)
P = Struct.new(:k1, :k2)
t("kwinit splat kw") { S.new(*e, k1: 1) }
t("kwinit splat ds") { S.new(*[], **{ z: 1 }) }
t("kwinit given") { S.new(*[1], k1: 1) }
t("kwinit empty ds") { S.new(*[], **{}) }
t("kwinit ds") { S.new(*e, **{ k1: 2 }) }
t("kwinit string") { S.new(*e, "k1" => 5) }
t("plain splat ds") { P.new(*[], **h) }
t("plain splat kw") { P.new(*e, k1: 1) }
t("plain given") { P.new(*[1], k1: 1) }
t("plain mixed") { P.new(*e, k2: 3, **{ k1: 4 }) }
t("plain string") { P.new(*e, "k2" => 6) }
t("plain over") { P.new(*[1, 2], k1: 1) }

# every argument runs before a `**` converts or a keyword is judged
$l = []
def lg(v) = ($l << v; v)
def u(l)
  $l.clear
  r = yield
  puts "#{l}: #{r.inspect} #{$l.inspect}"
rescue ArgumentError, TypeError => e
  puts "#{l}: #{e.class}: #{e.message} #{$l.inspect}"
end
def ko(p1, k1: 70) = [p1, k1]
def kq(k1: 70) = [k1]
def pr(*r, p1, k1:) = [r, p1, k1]
def pk(p1, **kw) = [p1, kw]
def nop = []
u("pos then ds") { ko(lg(1), **h) }
u("ds then lit") { k1(**h, k1: lg(1)) }
u("string then ds") { k1(k1: lg(1), "s" => lg(2), **hs) }
u("string twice") { kq("s" => lg(1), **hs) }
u("rest count") { pr(*[], k1: lg(1)) }
u("kwrest count") { pk(*[], "s" => lg(1)) }
u("true ds") { ko(lg(1), **true) }
u("true beside lit") { nop("s" => lg(1), **true) }
u("missing splat") { pr(lg(1), *[], lg(2)) }
bad = [1, {}][0]
u("bad ds then lit") { ko(lg(1), **bad, k1: lg(2)) }
u("ds then bad") { kq(**h, **true, k1: lg(1)) }
