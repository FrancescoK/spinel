# `a[i] op= x` on a Float array element that is nil raises NoMethodError, as
# `a[i] + x` does, for every arithmetic operator and every operand. The bare C
# operator carried the nil's NaN payload through and stored nil, both past the
# end of the array and in a gap a computed index left. An element the loop's
# header cache knows to be no nil is still folded in place with no test; the
# rest test it at the operator, after the right-hand side has run, which is
# when CRuby raises. An Integer array already raised and is pinned beside it.
K = 2

def try
  r = yield
  p r
rescue NoMethodError => e
  puts "NoMethodError: #{e.name}"
rescue TypeError, FrozenError => e
  puts e.class
end

def f_add(a, n) = (i = 0; while i < n; a[i] += 2; i += 1; end; a)
def f_const(a, n) = (i = 0; while i < n; a[i] += K; i += 1; end; a)
def f_mul(a, n, y) = (i = 0; while i < n; a[i] *= y; i += 1; end; a)
def f_mod(a, n) = (i = 0; while i < n; a[i] %= 2; i += 1; end; a)
def f_pow(a, n) = (i = 0; while i < n; a[i] **= 2; i += 1; end; a)
def f_div(a, n) = (i = 0; while i < n; a[i] /= 2.0; i += 1; end; a)
def f_call(a, n) = (i = 0; while i < n; a[i] += n.succ; i += 1; end; a)
def i_add(a, n) = (i = 0; while i < n; a[i] += 2; i += 1; end; a)

# in range of an array with no nil
try { f_add([1.5, 2.5], 2) }
try { f_call([1.5, 2.5], 2) }
# past the end
try { f_add([1.5, 2.5], 3) }
try { f_const([1.5, 2.5], 3) }
try { f_mul([1.5, 2.5], 3, 2.0) }
try { f_mod([1.5, 2.5], 3) }
try { f_pow([1.5, 2.5], 3) }
try { f_div([1.5, 2.5], 3) }
try { f_call([1.5, 2.5], 3) }
try { i_add([1, 2], 3) }
# a gap a computed index left
g = [1.0, 2.0]
g[g.size + 1] = 4.0
try { f_add(g.dup, 4) }
try { f_call(g.dup, 4) }

# the right-hand side runs before the raise, and the elements before the nil
# keep their new values
$log = []
def side(v) = ($log << v; v)
def ord(a, n) = (i = 0; while i < n; a[i] += side(i); i += 1; end; a)
a = [1.5, 2.5]
try { ord(a, 3) }
p $log, a

# a boxed right-hand side
def polyr(a, n, x) = (i = 0; while i < n; a[i] += x; i += 1; end; a)
try { polyr([1.5, 2.5], 2, [1, "s"][0]) }
try { polyr([1.5, 2.5], 3, [1, "s"][0]) }

# an array holding a nil the analysis sees, an ivar, negative indices, frozen
def twice(a) = (i = 0; while i < a.size; a[i] *= 2; i += 1; end; a)
try { twice([1.5, 2.5]) }
try { twice([1.5, nil, 2.5]) }
class Acc
  def initialize = (@v = [1.0, 2.0])
  def bump(n) = (i = 0; while i < n; @v[i] -= 0.5; i += 1; end; @v)
end
try { Acc.new.bump(2) }
try { Acc.new.bump(3) }
def neg(a) = (a[-1] += 1; a[-3] += 1; a)
try { neg([1.5, 2.5]) }
try { polyr([1.5, 2.5].freeze, 1, 1) }
