# A keyword whose key is an expression (`f(key(1) => v)`) names a keyword
# only when it has run, so it binds as a `**` does: into a named keyword,
# required or optional, or the `**kwrest`, and CRuby's missing and unknown
# keyword checks read it, a String key written ahead of it too. It runs
# ahead of its value, also where a splat makes the arguments run before the
# call is judged. It was dropped, value and all, and a String it carried
# into a keyword typed from an Integer default read back as pointer bits, as
# did a value of no type yet (`[]`).
$log = []
def tr(x) = ($log << x; x)
def f(*a, **k) = [a, k]
def g(a, k1:) = [a, k1]
def h(*a) = a
def r(key:) = key
def mk(a, key: 0, **k) = [a, key, k]
def n(key: 0) = key
def q(key:, other: 1) = [key, other]
def rest(**k) = k
class A; def m(key: 0, **k) = [:a, key, k]; def self.c(key:) = [:ac, key]; end
class P0; def m(key: 0) = [:p, key]; end
class P1 < P0; def m(key: 1) = super; end
class I; attr_reader :v; def initialize(key: 0, **k) = (@v = [key, k]); end
S = Struct.new(:key, :z, keyword_init: true)
lam = ->(key:, z: 0) { [key, z] }
class DM; define_method(:m) { |key: 0| [:dm, key] }; end
def fw(...) = A.new.m(...)
def y = yield(tr(:key) => "s")
def y2 = yield(k: 1, tr(:key) => 5)
def y3 = yield(tr(:key) => [])
def run
  $log.clear
  v = begin
    yield
  rescue ArgumentError, TypeError => e
    "#{e.class}: #{e.message}"
  end
  p [v, $log.dup]
end

xs = [1]
# the order they run in, after a splat too
run { f(*xs, tr(:key) => tr(:value)) }
run { f(tr(:a), *xs, tr(:k) => tr(:v)) }
run { g(*xs, tr(:z) => tr(:v)) }
run { g(*[], tr(:z) => tr(:v)) }
run { h(*xs, tr("s") => tr(2)) }
run { h(*xs, tr(:p) => tr(3), q: tr(4)) }
run { f(tr(:key) => tr(:value)) }
# what they bind
run { r(tr(:key) => 6) }
run { r(tr(:other) => 1) }
run { mk(1, tr(:key) => 2, tr(:z) => 3) }
run { mk(1, z: 0, tr(:z) => 4) }
run { n(tr("key") => 1) }
run { n(tr(:key) => "s") }
run { q(tr(:key) => [1, 2]) }
run { q(tr(:other) => :sym, key: 1.5) }
run { rest(tr(:a) => "x", b: 2) }
run { n(tr(:key) => []) }
run { n(tr(:key) => {}) }
run { r("s" => 1, tr(:key) => 6) }
run { r("s" => 1, tr(:other) => 6) }
# through the other call paths
run { A.new.m(tr(:key) => 1, tr(:z) => 2) }
run { A.c(tr(:key) => "s") }
run { A.new.send(:m, tr(:key) => 3) }
run { P1.new.m(tr(:key) => 9) }
run { I.new(tr(:key) => 6, tr(:w) => 7).v }
run { S.new(tr(:key) => 1, z: 2).to_a }
run { lam.call(tr(:key) => :x) }
run { DM.new.m(tr(:key) => 8) }
run { fw(tr(:key) => 11) }
run { y { |key: 0| key } }
run { y2 { |key: 0, k: 0| [key, k] } }
run { y3 { |key: 0| key } }
