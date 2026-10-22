# An Integer or Float array's element read `a[i]` is non-nil inside
# `while i < n` after `n = a.size`, as inside `while i < a.size`, when no nil
# can be in the array at run time (its static nil mark) -- a parameter's and
# an ivar's array too -- and a builtin that can only grow an array (`<<`,
# push, a one-index `[]=`) keeps the bound. Anything that can shrink the
# array, a write of n or of the array, or a nil that can reach it drops the
# proof, and those reads stay nil-capable where CRuby answers nil.
def run(name)
  p [name, yield]
rescue NoMethodError, TypeError => e
  p [name, e.class]
end

# an index list built from a counted loop that pushes, then read in a loop
# over its own length: kk is a plain Integer (infer-test)
def pick(ek, ed, mark, st)
  ed.clear
  ne = ek.length
  e = 0
  while e < ne
    ed << ek[e] if mark[ek[e]] != st
    e += 1
  end
  ed
end
def total(fl, hc)
  e = 0
  while e < fl.length
    kk = fl[e]
    hc[kk * 2] += 1
    e += 1
  end
  hc.sum
end
run("pick then total") { total(pick([0, 1, 2, 3], [], [1, 0, 1, 0], 0), Array.new(8, 0)) }

# a loop that writes another array's element: sx is a plain Integer
def scale(a, b, k)
  n = a.size
  i = 0
  while i < n
    sx = a[i]
    b[i] = sx * k + 1
    i += 1
  end
  b
end
run("scale") { scale([1, 2, 3], [0, 0, 0], 10) }

# a Float array held in an ivar
class Series
  def initialize(v) = @v = v
  def mean
    n = @v.size
    s = 0.0
    i = 0
    while i < n
      s += @v[i]
      i += 1
    end
    s / n
  end
end
run("ivar Float array") { Series.new([1.0, 2.0, 4.5]).mean }

# n = a.size, then the array shrinks: a[i] past the new end is nil
def shrunk(a)
  n = a.size
  a.pop
  s = 0
  i = 0
  while i < n
    s += a[i]
    i += 1
  end
  s
end
run("shrunk after n") { shrunk([1, 2, 3]) }

# ... shrinks inside the loop
def shrinks_in_loop(a)
  n = a.size
  s = 0
  i = 0
  while i < n
    s += a[i]
    a.delete_at(0) if i == 0
    i += 1
  end
  s
end
run("shrinks in the loop") { shrinks_in_loop([1, 2, 3]) }

# n is written again
def n_moved(a)
  n = a.size
  n += 1
  s = 0
  i = 0
  while i < n
    s += a[i]
    i += 1
  end
  s
end
run("n moved") { n_moved([1, 2, 3]) }

# the array is assigned again
def a_moved(a)
  n = a.size
  a = [1]
  s = 0
  i = 0
  while i < n
    s += a[i]
    i += 1
  end
  s
end
run("a moved") { a_moved([1, 2, 3]) }

# growth through another name keeps i < n
def grows(a)
  b = a
  n = a.size
  s = 0
  i = 0
  while i < n
    s += a[i]
    b << 9
    i += 1
  end
  s
end
run("grows through another name") { grows([1, 2, 3]) }

# a nil stored through another name: the static mark drops the proof
H = {1 => 5}
def add(x, k) = x << H[k]
def nil_through(a)
  add(a, 7)
  n = a.size
  s = 0
  i = 0
  while i < n
    s += a[i]
    i += 1
  end
  s
end
run("nil through a parameter") { nil_through([1, 2]) }

# a gap a write past the end left
def gap(a)
  a[4] = 1
  n = a.size
  s = 0
  i = 0
  while i < n
    s += a[i]
    i += 1
  end
  s
end
run("gap") { gap([1, 2]) }
