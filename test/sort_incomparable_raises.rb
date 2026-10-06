# Two values that do not compare make sort, sort_by, min, max, minmax and
# minmax_by raise ArgumentError ("comparison of A with b failed"), named as
# CRuby names the pair.
#
# A comparator block that answers nil raises through the comparator path
# (#7646); its cases stay here beside the key and pair ones. sort_by's key
# order kept an incomparable pair of keys where it stood, and an Integer or
# Float key that may be nil was boxed as a number. minmax and minmax_by
# walked one element at a time where CRuby walks pairs, so a failing pair
# was named the other way round.
#
# The sorts compare two-element arrays here: which pair a longer sort meets
# first is the platform's qsort's choice in CRuby.

def t(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue ArgumentError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

class V
  include Comparable
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = o.is_a?(V) ? v <=> o.v : nil
  def inspect = "V#{v}"
end

class C
  include Enumerable
  def each
    yield 1
    yield 2
  end
end

# sort / sort! with a block
t("poly sort") { [3, "a"].sort { |a, b| a <=> b } }
t("poly sort!") { x = [3, "a"]; x.sort! { |a, b| a <=> b } }
t("int nil") { [3, 1].sort { |a, b| nil } }
t("int sort! nil") { [3, 1].sort! { |a, b| nil } }
t("str nil") { %w[b a].sort { |a, b| nil } }
t("flt nil") { [1.5, 0.5].sort { |a, b| nil } }
t("nil arm") { [3, 1].sort { |a, b| a == 3 ? nil : a <=> b } }
t("nan") { [0.0 / 0.0, 1.0].sort { |a, b| a <=> b } }
t("user") { [V.new(2), 3].sort { |a, b| a <=> b } }
t("hash") { { a: 1, b: 2 }.sort { |x, y| nil } }
t("enum") { C.new.sort { |a, b| nil } }
t("one") { [1].sort { |a, b| nil } }

# sort_by / sort_by!
t("sort_by nil") { [1, 2].sort_by { |x| x == 2 ? nil : x } }
t("sort_by! nil") { x = [1, 2]; x.sort_by! { |v| v == 1 ? nil : v } }
t("sort_by str") { [1, 2].sort_by { |x| x == 2 ? "s" : x } }
t("sort_by flt") { [1.5, 2.5].sort_by { |x| x > 2 ? nil : x } }
t("sort_by strs") { %w[a b].sort_by { |x| x == "b" ? nil : x } }
t("sort_by poly") { [1, "a"].sort_by { |x| x == "a" ? nil : x } }
t("sort_by bool") { [1, 2].sort_by { |x| x > 1 } }
t("sort_by user") { [V.new(2), 3].sort_by { |x| x } }
t("sort_by hash") { { a: 1, b: 2 }.sort_by { |k, v| v == 2 ? nil : v } }
t("sort_by range") { (1..2).sort_by { |x| x == 2 ? nil : x } }
t("sort_by enum") { C.new.sort_by { |x| x == 2 ? nil : x } }
# keys that compare still sort, and nil ties with nil
t("sort_by all nil") { [1, 2].sort_by { nil } }
t("sort_by same bool") { [2, 1].sort_by { true } }
t("sort_by mixed num") { [1, 2].sort_by { |x| x == 1 ? 1.5 : x } }
t("sort_by users") { [V.new(2), V.new(1)].sort_by { |x| x } }
t("sort_by arrays") { [[2, 1], [1, 9]].sort_by { |x| x } }
t("sort_by keys") { [3, 1, 2].sort_by { |x| -x } }

# min / max with a block
t("min nil") { [3, 1, 2].min { |a, b| nil } }
t("max nil") { [3, 1, 2].max { |a, b| nil } }
t("poly min") { [3, "a", 1].min { |a, b| a <=> b } }
t("poly max") { [3, "a", 1].max { |a, b| a <=> b } }
t("min nil arm") { [2, 1].min { |a, b| a == 1 ? nil : a <=> b } }
t("max strs") { %w[a b].max { |a, b| nil } }
t("max nan") { [1.0, 0.0 / 0.0].max { |a, b| a <=> b } }
t("max(2) nil") { [3, 1, 2].max(2) { |a, b| nil } }
t("enum min") { C.new.min { |a, b| nil } }

# minmax with a block, minmax_by
t("minmax nil") { [3, 1, 2].minmax { |a, b| nil } }
[[1, 2, 3], [1, 2, 3, 4], [3, 1, 2, 5, 4]].each do |a|
  a.size.times do |k|
    t("minmax #{a} #{k}") { a.minmax { |x, y| x == a[k] || y == a[k] ? nil : x <=> y } }
    t("minmax_by #{a} #{k}") { a.minmax_by { |x| x == a[k] ? nil : x } }
  end
end
t("minmax_by str") { [1, 2, 3].minmax_by { |x| x == 3 ? "s" : x } }
t("enum minmax") { C.new.minmax { |a, b| nil } }
t("enum minmax_by") { C.new.minmax_by { |x| x == 2 ? nil : x } }
p [[2, 0], [1, 1], [2, 2], [1, 3]].minmax { |a, b| a[0] <=> b[0] }
p [[2, 0], [1, 1], [2, 2], [1, 3], [0, 4]].minmax_by { |a| a[0] }
p({ a: 2, b: 1, c: 2 }.minmax_by { |k, v| v })
