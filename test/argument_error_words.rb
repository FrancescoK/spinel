# Every binder refuses a call in CRuby's words, whichever path bound it. A
# count error names the callee's required keywords after the range, supplied
# or not, through a splat, a gather, a lambda or a dispatch arm as through a
# plain call; a missing or unknown keyword error names every such keyword,
# each as #inspect writes it; a `**nil` method refuses keywords before it
# counts; and a keyword_init Struct or a Data given a `*` counts what the
# splat really holds, a Data then naming its missing members or unknown keys.
def t(l)
  r = yield
  puts "#{l}: ok #{r.inspect}"
rescue ArgumentError => e
  puts "#{l}: #{e.message}"
end

# the count, with the required keywords named after it
def rk(p1, k1:) = [p1, k1]
def rk2(a, b = 1, k:, j:) = a
e = []
three = [1, 2, 3]
t("splat lit") { rk(*[]) }
t("splat var") { rk(*e) }
t("splat mid") { rk(*e, 1, 2, k1: 1) }
t("gather") { rk2(*three, k: 1, j: 1) }
f = ->(k1:) { [k1] }
t("lambda") { f.call(1) }
g = ->(a, b = 2, *r, k:, j: 1) { a }
t("lambda rest") { g.call(k: 1) }
class A; def m(a, k:) = [a, k]; def n(a, b = 1, k:, j:) = a; end
class B; def m(a, k:) = [a]; def n(x) = x; end
o = [A.new, B.new, 1][0]
t("poly arm") { o.m(k: 1) }
t("poly none") { o.n }
t("poly splat") { o.m(*three, k: 1) }

# every missing keyword, then every unknown one, once each
def mk(a, k:, j:) = a
def ok(a, k: 1) = a
t("missing") { mk(1) }
t("missing one") { mk(1, k: 1, zz: 2) }
t("unknown") { ok(1, z: 1, k: 2, y: 2) }
t("unknown str") { ok(1, "s" => 1, z: 2) }
t("unknown quoted") { ok(1, "a b": 1, z: 2, z: 3) }
t("dispatch") { A.new.n(1) }
pr = proc { |k:, j:| k }
t("proc") { pr.call }
h = { z: 1, y: 2 }
t("kw splat") { ok(1, **h) }
class N; def self.new(a, k:, j:) = [a, k, j]; end
class M; def self.new(a, k:, j:) = [a]; end
cls = [N, M][0]
t("class value") { cls.new(1) }
DS = Data.define(:a, :b, :c) do
  def initialize(**kw) = super(**kw)
end
t("data super") { DS.new(a: 1) }
DW = Data.define(:a)
t("data with") { DW.new(a: 1).with(z: 1, y: 2, "s" => 3) }

# `**nil` refuses keywords ahead of the count
def nk(**nil) = []
def nk2(a, **nil) = [a]
bh = [{ z: 1 }, 0][0]
t("nokw boxed") { nk(**bh) }
t("nokw literal") { nk(z: 1) }
t("nokw count") { nk2(**h) }
t("nokw empty") { nk(**{}) }

# a keyword_init Struct counts what the call passes
KS = Struct.new(:p1, :p2, keyword_init: true)
t("kwinit splat") { KS.new(*[1, 2]) }
t("kwinit nil") { KS.new(1, **nil) }
t("kwinit mid") { KS.new(*e, 1) }

# a Data given a `*`: its count, then its keywords by name
D0 = Data.define
D1 = Data.define(:k1)
D2 = Data.define(:a, :b)
one = [1]
t("data short") { D1.new(*e) }
t("data empty") { D1.new(*[]) }
t("data kw") { D0.new(*e, z: 1) }
t("data str") { D0.new(*[], "s" => 1) }
t("data dup") { D0.new(*[], y: 1, y: 2) }
t("data empty kw") { D1.new(*[], **{}) }
t("data mixed") { D2.new(*one, a: 1) }
t("data long") { D2.new(*three) }
t("data none") { D0.new(*one) }
t("data builds") { D2.new(*e, a: 1, b: 2) }
t("data builds str") { D2.new(*e, "a" => 1, "b" => 2) }
t("data builds pos") { D2.new(*[1], 2) }
t("data by name") { D1.new(*e, k1: 1) }
