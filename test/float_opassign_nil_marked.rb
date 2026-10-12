# `a[i] op= x` on a Float array folds in place (one bounds test, one address)
# up to the array's nil-free length, which its nil bitmap sets at run time. An
# array analyze marks as able to hold nil -- written at an index it cannot
# prove in range, or with a value that can be nil -- folds too: every way a nil
# gets in sets the bitmap, so a nil slot still takes the get/set that raises
# NoMethodError as `a[i] + x` does, and the slots ahead of it still add.

def zero_then_add(h, n)
  b = 0
  while b < n
    h[b] = 0.0            # a write at a computed index: it could leave a gap
    b += 1
  end
  j = 0
  while j < n
    h[j] += 1.5           # folded, in the loop's header cache
    j += 1
  end
  h
end
p zero_then_add(Array.new(4, 9.0), 4)

# A nil reaches each array below through a Float that can be nil (never a nil
# literal, which makes the array a boxed one). Each slot ahead of it adds; the
# nil one raises, in a cached loop and outside one.
def in_loop(h)
  j = 0
  while j < h.length
    h[j] += 1.0
    j += 1
  end
rescue NoMethodError => e
  puts "loop: #{e.message}"
end

def tail_mul(h)
  h[h.length - 1] *= 2.0
rescue NoMethodError => e
  puts "last: #{e.message}"
end

def check(at, h)
  print at, " "
  in_loop(h)
  tail_mul(h)
  p h
end

def maybe(v, keep) = keep ? v : nil
none = ARGV.size > 0      # false: every maybe below is nil

a = [1.0, 2.0, 3.0]
a[1] = maybe(5.0, none)
check("store", a)

b = [1.0, 2.0]
b[3] = 4.0                # the gap at 2 is nil
check("gap", b)

c = [1.0, 2.0]
c << maybe(3.0, none)
c.push(7.0)
check("push", c)

d = [1.0, 2.0, 3.0]
d.insert(1, maybe(9.0, none))
check("insert", d)

e = [1.0, 2.0]
e.unshift(maybe(0.5, none))
check("unshift", e)

f = [1.0, 2.0]
f.concat([maybe(8.0, none), 3.0])
check("concat", f)

g = [1.0, 2.0, 3.0, 4.0]
g[1, 2] = [maybe(5.0, none), 6.0]
check("slice", g)

k = [1.0, 2.0, 3.0]
k.fill(maybe(0.0, none), 2)
check("fill", k)

m = [1.0, 2.0, 3.0].map { |v| v == 2.0 ? maybe(v, none) : v }
check("map", m)

n = Array.new(3, 0.0)
n[0] = maybe(1.0, none)
check("new", n)
