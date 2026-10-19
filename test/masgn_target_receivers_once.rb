# spinel: gc-stress
# Each target of a multiple assignment evaluates its receiver and index once,
# before any value and left to right, the splat's target, the rights' and
# those nested in a `(a, b)` beside the lefts: a receiver that can be nil is
# tested before the store and used for it, so a call in it must not run
# again for the test.
class P
  attr_accessor :a, :b
end

$log = []
$n = 0
$cur = nil

def pk(tag)
  $log << tag
  P.new
end

def ix(tag, i)
  $log << tag
  i
end

def rhs
  $log << "rhs"
  [1, [2, 3], 4]
end

# a receiver that is nil on a later call
def mk
  $n += 1
  $cur = $n > 100 ? nil : P.new
end

def count(label)
  $n = 0
  yield
  p [label, $n]
end

count("nested left") { (mk.a, mk.b), c = [1, 2], 3 }
count("nested right") { c, (mk.a, mk.b) = 3, [1, 2] }
count("rights") { *r, mk.a = 1, 2, 3 }
count("rights after lefts") { x, *r, mk.a, mk.b = 1, 2, 3, 4 }
count("splat") { x, *mk.a = 1, 2, 3 }
count("deep") { x, (y, (mk.a, mk.b)) = 1, [2, [3, 4]] }
count("array value") { v = [1, 2]; (mk.a, mk.b), c = v, 3 }
count("lefts") { mk.a, mk.b = 1, 2 }

(mk.a, mk.b), c = [3, 4], 5
p [$cur.a, $cur.b, c]

$n = 99
begin
  (mk.a, mk.b), c = [3, 4], 5
rescue NoMethodError => e
  p [e.class, $n]
end

ARR = [0, 0, 0, 0, 0, 0]
H = {}
(pk("r1").a, (pk("r2").b, ARR[ix("k1", 1)])), *H[ix("k2", :s)], pk("r3").a = rhs
p $log
p ARR
p H

$log.clear
x, (ARR[ix("k3", 2)], pk("r4").a), *r, ARR[ix("k4", 3)] = 9, [8, 7], 6, 5, 4
p $log
p ARR
p r

$log.clear
pk("l1").a, (pk("l2").a, pk("l3").a), pk("l4").b = 1, [2, 3], 4
p $log
