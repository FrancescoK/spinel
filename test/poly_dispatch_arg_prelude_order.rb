# The arguments of a call on a boxed receiver run in the order they are
# written. One that builds a value ahead of it -- an Array or Hash literal,
# or statements before its value -- had that part written ahead of the whole
# dispatch, so it ran before the receiver and before every argument written
# earlier: `o.m(k2: (log 2; 2), k1: (log 1; [1]))` logged 1 before 2. It
# runs in its place now: positionals, keywords, and keywords beside a `**`.

$l = []
def log(v) = ($l << v; v)

class A
  def m(a, b) = [:a, a, b]
  def k(k1: 0, k2: 0, **o) = [:a, k1, k2, o]
end
class B
  def m(a, b) = [:b, a, b]
  def k(k1: 0, k2: 0, **o) = [:b, k1, k2, o]
end

h = {}
[A.new, B.new].each do |o|
  $l.clear
  p o.k(k2: (log 2; 2), k1: (log 1; [1])), $l
  $l.clear
  p o.k(k1: (log 1; 1), k2: (log 2; [2])), $l
  $l.clear
  p o.m((log 1; 1), (log 2; [2])), $l
  $l.clear
  p o.m((log 1; 1), (log 2; {a: 2})), $l
  $l.clear
  p (log 0; o).m((log 1; [1]), 2), $l
  $l.clear
  p o.k(k2: (log 2; 2), **h, k1: (log 1; [1])), $l
  $l.clear
  p o.k(k2: (log 2; 2), **(log 3; {z: [3]})), $l
end
