# A callable forwarded with `&` to a Hash iterator when the compiler cannot
# see its parameters -- one held in a boxed (poly) slot, `h.map(&q)` with
# `q = [proc { |k, v| }, 1][0]`, or a Proc a method returned -- and one that
# is not a plain read at all (`h.map(&a[0])`, `h.map(&mk)`).
#
# The forward becomes a literal block that calls the callable, and for a
# Hash the call takes the pair as one array or the key and value as two by
# the callable's arity. With no arity to read the desugar declined, and with
# no plain read to re-read per element it declined too; either way the call
# stayed in its &-form and raised NoMethodError at run time. The callable now
# gets the pair, which a Proc auto-splats; map and find ask a boxed one's
# arity at run time; and an expression is evaluated once, into a temp, after
# the receiver and before the call.
#
# Each iterator hands a lambda or a Method what CRuby's does: Hash's own
# select, filter, reject and to_h yield the key and the value as two, map
# spreads the pair for more than one required parameter, find treats a
# lambda as a Proc and a Method strictly, and the rest raise for a second
# required parameter.
h = { a: 1, b: 2 }
kv = [proc { |k, v| "#{k}=#{v}" }, 1][0]
one = [proc { |x| x.inspect }, 1][0]
big = [proc { |k, v| v > 1 }, 1][0]
key = [proc { |x| x == :a }, 1][0]

p h.map(&kv), h.collect(&kv), h.map(&one)
p h.each(&kv), h.each_pair(&one)
p h.select(&big), h.filter(&big), h.reject(&big)
p h.select(&key), h.reject(&key)
sv = [proc { |k, v| v * 10 }, 1][0]
neg = [proc { |k, v| -v }, 1][0]
sw = [proc { |k, v| [v, k] }, 1][0]
fm = [proc { |k, v| k if v > 1 }, 1][0]
p h.sum(&sv), h.min_by(&sv), h.max_by(&sv), h.sort_by(&neg)
p h.to_h(&sw), h.flat_map(&sw), h.filter_map(&fm)
p h.find(&big), h.any?(&big), h.all?(&big), h.count(&big), h.group_by(&big), h.partition(&big)
ew = [proc { |(k, v), memo| memo << k }, 1][0]
p h.each_with_object([], &ew)

# each runs the proc for its effect: one that captures an outer local and
# changes it sees every pair
seen = []
total = 0
acc = [proc { |k, v| seen << k; total += v }, 1][0]
h.each(&acc)
p seen, total

# held in an instance variable, and read through a method parameter
class Box
  def initialize(q) = (@q = q)
  def run(h) = h.map(&@q)
  def keep(h) = h.select(&@q)
  def self.over(h, q) = h.map(&q)
end
b = Box.new([proc { |k, v| v.odd? }, 1][0])
p b.run(h), b.keep(h)
p Box.over(h, kv), Box.over(h, one)

# a Proc a method returned is as opaque, and one taking |*a| takes the pair
def mk = proc { |k, v| "#{k}:#{v}" }
f = mk
rest = proc { |*a| a }
p h.map(&f), h.map(&rest), h.select(&rest)

# a Proc whose arity is visible: |x| sees the key where Hash yields two
px = proc { |x| x == :a }
p h.select(&px), h.reject(&px), h.to_h(&proc { |k, v| [k.to_s, v] })

# an anonymous & forwarded to select yields the key and the value as two
class Sel
  def initialize = (@h = { a: 1, b: 2 })
  def sel(&) = @h.select(&)
end
p Sel.new.sel { |x| x == :a }, Sel.new.sel { |k, v| v > 1 }

# lambdas and Methods, visible and boxed: what each one is handed
got = []
lkv = ->(k, v) { got << [k, v]; v }
lo = ->(k, v = 0) { got << [k, v]; v }
lr = ->(*a) { got << a; 1 }
l1 = ->(x) { got << x; x }
def m2(k, v) = "#{k}:#{v}"
def mo(k, v = 0) = "#{k};#{v}"
def m1(x) = x.inspect
mm = method(:m2)
p h.map(&lkv), h.map(&lo), h.map(&lr), h.map(&l1), h.map(&mm), h.map(&method(:mo))
p h.find(&lkv), h.find(&lo), h.find(&lr), got
got.clear
p((h.find(&mm) rescue $!.class))
p((h.each(&lkv) rescue $!.class))
p((h.count(&lkv) rescue $!.class))
p((h.flat_map(&mm) rescue $!.class))
p((h.any?(&method(:m2)) rescue $!.class))
p h.select(&lkv), h.reject(&lo), h.select(&mm), h.select(&method(:m2))
p((h.select(&l1) rescue $!.class))
p((h.select(&method(:m1)) rescue $!.class))
p got
got.clear
blkv = [lkv, 1][0]
blo = [lo, 1][0]
bl1 = [l1, 1][0]
def n2(k, v) = "#{k}:#{v}"
def no(k, v = 0) = "#{k};#{v}"
def n1(x) = x.inspect
bm2 = [method(:n2), 1][0]
bmo = [method(:no), 1][0]
bm1 = [method(:n1), 1][0]
p h.map(&blkv), h.map(&blo), h.map(&bl1), h.map(&bm2), h.map(&bmo), h.map(&bm1)
p h.find(&blkv), h.find(&blo), got
p((h.find(&bm2) rescue $!.class))
p((h.each(&blkv) rescue $!.class))
p((h.partition(&bm2) rescue $!.class))
p h.select(&blkv), h.select(&bm2), h.each(&bl1), h.each(&bm1)
p((h.select(&bl1) rescue $!.class))
p((h.reject(&bm1) rescue $!.class))

# not a plain read: evaluated once, after the receiver and before the call
def lit(x) = (puts "lit #{x.inspect}"; x)
def made = (puts "made"; proc { |x| [x] })
def made2 = (puts "made2"; proc { |k, v| v })
def via(q) = (puts "via"; q)
cbs = [proc { |x| x * 2 }, proc { |k, v| k }]
p [1, 2].map(&cbs[0]), (1..3).map(&cbs[0]), h.map(&cbs[1]), h.each(&cbs.last)
p [1, 2].select(&cbs.first), (1..2).reject(&cbs.first), [3, 1].sort_by(&cbs[0])
p [1, 2].map(&made), h.map(&made2), (1..2).each(&via(cbs[0])), h.select(&via(cbs[1]))
p lit([1, 2]).map(&via(cbs[0])), lit(h).each_with_object([], &via(ew))
n = 0
bump = [proc { |x| n += x }]
[1, 2, 3].each(&bump[0])
p n
p h.map(&[lkv, 1].first), h.map(&[mm][0]), h.find(&[lo][0])

# each_slice and each_cons hand one Array per step, and each_entry answers its
# receiver: a Hash or a Range reaches them through a `to_a` hop, and the
# receiver the call answers ran a second time where it was read as the answer
sl = [proc { |a, b| got << [a, b] }, 1][0]
got.clear
p [1, 2, 3].each_slice(2, &sl), (1..4).each_cons(3, &cbs[0].>>(proc { |x| got << x })), got
got.clear
p h.each_slice(1, &l1), [1, 2, 3].each_cons(2, &made), got
p((h.each_slice(1, &lkv) rescue $!.class), ([1, 2].each_cons(2, &bm2) rescue $!.class))
p h.each_entry(&made), (1..2).each_entry(&via(cbs[0])), (1..3).each_slice(2, &made)
e = [3, 4].each_slice(1)
p e.each_entry(&made), e.each_slice(1, &via(sl))
p((z = lit(1); 1..2).each_entry { |x| x }, (z = lit(2); h).each_slice(1) { |x| x })
p lit(1..3).each_cons(2) { |x| x }, (z = lit(3); [3, 4].each_slice(1)).each_entry { |x| x }

# an Array's or a Range's to_h takes the element and answers the pair
pairs = [proc { |x| [x, x * 2] }]
p [1, 2].to_h(&pairs[0]), (1..2).to_h(&made.>>(proc { |v| [v[0], 0] })), [[1, 2]].to_h(&sl.>>(proc { got.last }))
p(([1].to_h(&cbs[0]) rescue $!.class))
