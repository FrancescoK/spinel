# A positional argument whose value is nil runs where it is written, ahead
# of the keywords, when the call's keywords run ahead of the binding (a key
# a `**` writes again, or a `**` with an effect): taken for a raise, which
# has no value, it was skipped there, so it ran after the keywords, or never
# when their check raised `unknown keyword`; and a read a `**` operand
# after it rewrites is read in its place. Through a method and a
# define_method's block.
$l = []
class C
  define_method(:m) { |p1, k1:| [p1, k1] }
  def d(p1, k1:) = [p1, k1]
end
h = { z: 6 }
begin
  C.new.m(($l << 1; nil), k1: ($l << 2; 2), z: ($l << 3; 3), **h)
rescue ArgumentError => e
  p e.message, $l
end
$l.clear
begin
  C.new.d(($l << 1; nil), k1: ($l << 2; 2), z: ($l << 3; 3), **h)
rescue ArgumentError => e
  p e.message, $l
end
$l.clear
p C.new.m(($l << 1; nil), k1: ($l << 2; 2)), $l
$l.clear
p C.new.m(($l << 1; nil), k1: ($l << 2; 2), **{}), $l

# a positional read a `**` operand after it rewrites is read in its place
def mk(a, **kw) = [a, kw]
x = 1
p mk(x, **(x = { z: 2 }))
def gy(h) = ($gy = 5; h)
$gy = 1
p mk($gy, **gy({ q: 1 }))
def nk(a, k: 0) = [a, k]
w = 3
p nk(w, **(w = { k: 9 }))
