# A Float array element compared with `< <= > >=` in a loop that holds the
# array's header is a plain load in range of an array with no nil, as under
# `+ - * /`; past the end, or in a gap a computed index left, its nil raises
# as CRuby's comparison does: NoMethodError on the left, ArgumentError on
# the right, and NoMethodError when both sides are nil.
F = 2.5

def try
  yield
rescue NoMethodError, ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

def right(a, x, n)           # the element on the right
  c = 0
  i = 0
  while i < n
    c += 1 if x < a[i]
    c += 10 if x >= a[i]
    i += 1
  end
  c
end

def left(a, x, n)            # the element on the left, against a local
  c = 0
  i = 0
  while i < n
    c += 1 if a[i] <= x
    c += 10 if a[i] > x
    i += 1
  end
  c
end

def left_const(a, n)         # ... against a constant
  c = 0
  i = 0
  while i < n
    c += 1 if a[i] > F
    i += 1
  end
  c
end

def both(a, b, n)            # an element on each side
  c = 0
  i = 0
  while i < n
    c += 1 if a[i] < b[i]
    i += 1
  end
  c
end

def back(a, x)               # negative indices count from the end
  c = 0
  i = 1
  while i <= a.size
    c += i if x < a[-i]
    i += 1
  end
  c
end

class Holder
  attr_accessor :v
  def initialize = @v = nil
end

def through(h, x, n)         # a receiver that may be nil
  c = 0
  i = 0
  while i < n
    c += 1 if x < h.v[i]
    i += 1
  end
  c
end

def left_first(a, h, s, n)   # a right operand that raises raises first
  c = 0
  i = s
  while i < n
    c += 1 if a[i] < h.v[i]
    i += 1
  end
  c
end

def nilable(a, n)            # a left operand that may itself be nil
  c = 0
  i = 0
  while i < n
    l = i.even? ? 1.0 : nil
    c += 1 if l < a[i]
    i += 1
  end
  c
end

a = [1.0, 2.0, 3.0, 4.0]
p right(a, 2.5, 4), left(a, 2.5, 4), left_const(a, 4), both(a, [0.0, 5.0, 5.0, 0.0], 4), back(a, 2.5)
try { p right(a, 2.5, 5) }
try { p left(a, 2.5, 5) }
try { p left_const(a, 5) }
try { p both(a, [9.0, 9.0], 3) }
try { p both([1.0], [9.0], 2) }
g = [1.0]
g[3] = 4.0                   # g[1] and g[2] are nil
try { p right(g, 0.5, 4) }
try { p left(g, 0.5, 4) }
h = Holder.new
p through(h, 1.0, 0)
try { p through(h, 1.0, 1) }
h.v = [2.0, 0.0]
p through(h, 1.0, 2)
try { p through(h, 1.0, 3) }
p nilable([2.0], 1)
try { p nilable([2.0, 3.0], 2) }
try { p nilable([2.0], 2) }
hv = Holder.new
hv.v = [5.0, 0.0]
p left_first([1.0, 2.0], hv, 0, 2)
try { p left_first([1.0], Holder.new, 1, 2) }
