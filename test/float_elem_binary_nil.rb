# A Float array element read in a loop that holds the array's header is a
# plain load in range of an array with no nil, on either side of a binary
# `+ - * /` as in an op-assign; past the end, or in an array a computed
# index left a gap in, its nil raises as CRuby's does: NoMethodError on the
# left, TypeError on the right. A constant operand is a plain read too, so
# `a[i] += K` takes the same in-place fold as `a[i] += 4`.
K = 2
F = 0.5

def try
  yield
rescue NoMethodError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

def left(a, n)               # the element on the left
  t = 0.0
  i = 0
  while i < n
    t += a[i] + F
    i += 1
  end
  t
end

def right(a, n)              # the element on the right
  t = 0.0
  i = 0
  while i < n
    t += F * a[i]
    i += 1
  end
  t
end

def int_left(a, n)           # an Integer constant on the right
  t = 0.0
  i = 0
  while i < n
    t += a[i] - K
    i += 1
  end
  t
end

def div_right(a, n)          # the element as a divisor
  t = 0.0
  i = 0
  while i < n
    t += K / a[i]
    i += 1
  end
  t
end

def opw_const(a, n)          # op-assign with a constant operand (in range only)
  i = 0
  while i < n
    a[i] += K
    a[i] *= F
    i += 1
  end
  a
end

a = [1.5, 2.5]
try { p left(a, 2) }
try { p left(a, 3) }
try { p right(a, 2) }
try { p right(a, 3) }
try { p int_left(a, 2) }
try { p int_left(a, 3) }
try { p div_right(a, 2) }
try { p div_right(a, 3) }
try { p opw_const([1.5, 2.5], 2) }

g = [1.0, 2.0]
k = a.size + 1
g[k] = 4.0
try { p left(g, 2) }
try { p left(g, 4) }
try { p right(g, 4) }
try { p div_right(g, 4) }
