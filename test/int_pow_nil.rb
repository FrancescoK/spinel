# Integer `**` with a nil operand raises as the other operators do:
# NoMethodError for nil on the left, the coercion TypeError for nil on the
# right. sp_int_pow ran no nil test, so the nil sentinel (INTPTR_MIN) was
# computed on: `nil ** 2` raised RangeError "integer overflow in **", and
# `3 ** nil` RangeError "negative exponent", the sentinel being negative.
K = 2

def try
  r = yield
  p r
rescue NoMethodError => e
  puts "NoMethodError: #{e.name}"
rescue TypeError, RangeError => e
  puts e.class
end

def sq(v) = v ** 2
def ex(v) = 3 ** v
def pw(v, e) = v.pow(e)
def cube(v) = (x = v; x **= 3; x)
def elem(a, n) = (t = 0; i = 0; while i < n; t = a[i] ** K; i += 1; end; t)
def opw(a, n) = (i = 0; while i < n; a[i] **= 2; i += 1; end; a)

try { sq(7) }
try { sq(nil) }
try { ex(4) }
try { ex(nil) }
try { pw(2, 10) }
try { pw(nil, 2) }
try { pw(2, nil) }
try { cube(3) }
try { cube(nil) }
try { elem([5, 7], 2) }
try { elem([5, 7], 3) }
try { opw([5, 7], 2) }
try { opw([5, 7], 3) }
g = [5, 7]
g[g.size + 1] = 9
try { opw(g, 4) }
try { 3 ** -1 }
