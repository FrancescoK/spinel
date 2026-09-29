# A class method called on a value that may be one of several classes: a
# class whose method cannot take the call still gets its arm, which raises
# that method's ArgumentError (a count, a missing or unknown keyword) once
# the arguments have run, where the call answered NoMethodError. One class
# refusing never raises for a value of another, a splat's count included.
# The arguments run in source order: a `*` or `**` operand where it stands,
# so a `**true` raises its TypeError before the values written after it.
$l = []
def lg(x) = ($l << x; x)
class A
  def self.m(p1, *r, k: 0, **kw) = [:a, p1, r, k, kw]
  def self.n(p1) = [:a, p1]
  def self.q(p1, k: 0) = [:a, p1, k]
  def self.p(a, h = {}) = [:a, a, h]
  def self.z(a, *r, **nil) = [:a, a, r]
  def self.w(*r) = r.size
end
class B
  def self.m(p1, p2 = 5, k:) = [:b, p1, p2, k]
  def self.n(p1, p2) = [:b, p1, p2]
  def self.q(p1, &b) = [:b, p1, b ? b.call : nil]
  def self.p(a, h) = [:b, a, h]
  def self.z(a, b = 2, **nil) = [:b, a, b]
  def self.w(*r) = -r.size
end
def t(label)
  $l.clear
  r = yield
  puts "#{label} #{r.inspect} #{$l.inspect}"
rescue => e
  puts "#{label} #{e.class}: #{e.message} #{$l.inspect}"
end
h = { k: 3 }
hp = [{ k: 7 }, 1][0]
tr = true
one = [1]
two = [1, 2]
pr = proc { :pr }
nl = [nil, 1][0]
[A, B].each do |o|
  t("n0") { o.n }
  t("n1") { o.n(lg(1)) }
  t("n2") { o.n(lg(1), lg(2)) }
  t("n3") { o.n(lg(1), lg(2), lg(3)) }
  t("nk") { o.n(lg(1), k: lg(2)) }
  t("n*1") { o.n(*one) }
  t("n*2") { o.n(*two) }
  t("m*") { o.m(lg(1), *lg([2, 3]), k: lg(4)) }
  t("m**") { o.m(lg(1), **lg(h), k: lg(9)) }
  t("m**h") { o.m(lg(1), **hp) }
  t("m**nil") { o.m(lg(1), **nil) }
  t("m**true") { o.m(lg(1), z: lg(2), **tr, k: lg(3)) }
  t("q") { o.q(lg(1), k: lg(2)) { :blk } }
  t("q&") { o.q(lg(1), k: lg(2), &pr) }
  t("p**") { o.p(lg(1), **lg(h), s: lg(2)) }
  t("p**true") { o.p(lg(1), **tr, s: lg(2)) }
  t("p**nil") { o.p(lg(1), **nl) }
  t("z**true") { o.z(lg(1), *[lg(2)], lg(3), **tr) }
  t("z**") { o.z(lg(1), **lg(h)) }
end
2.times do |i|
  o = [A, B][i]
  t("idx") { o.m(*lg([1]), k: lg(2), zz: lg(3)) }
  t("idx**") { o.m(lg(1), **tr, k: lg(2), k: lg(3)) }
end
[A, B, 5, "S"].each { |o| t("x") { o.n(lg(1)) } }
# more arguments than the override table holds: the `**` still runs once
# (its value is counted, not the order past the table)
[A, B].each do |o|
  $l.clear
  p [o.w(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10), lg(11), lg(12), lg(13), lg(14), lg(15), lg(16),
               lg(17), lg(18), lg(19), lg(20), lg(21), lg(22), lg(23), lg(24), lg(25), lg(26), lg(27), lg(28), lg(29), lg(30), lg(31), lg(32),
               lg(33), lg(34), lg(35), lg(36), lg(37), lg(38), lg(39), lg(40), lg(41), lg(42), lg(43), lg(44), lg(45), lg(46), lg(47), lg(48),
               lg(49), lg(50), lg(51), lg(52), lg(53), lg(54), lg(55), lg(56), lg(57), lg(58), lg(59), lg(60), lg(61), lg(62), lg(63), lg(64),
               **lg(h)), $l.size, $l.count(h)]
end
