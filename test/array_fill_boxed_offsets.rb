# Array#fill with its start or length read out of a boxed slot: an Integer,
# nil and a negative start as CRuby takes them, a Range followed by a length
# and a String are CRuby's TypeError. A boxed Range was read as 0 and the
# whole array filled.
def w(v) = v
p(([].fill("x", w(0..2), 5) rescue [$!.class, $!.message]))
p [1, 2, 3].fill(9, w(1))
p [1, 2, 3].fill(9, w(1), w(1))
p [1, 2, 3].fill(9, w(nil), w(2))
p [1, 2, 3].fill(9, w(-2))
p(([1].fill(9, w("a")) rescue [$!.class, $!.message]))
p [1, 2, 3].fill(9, 1, w(nil))
