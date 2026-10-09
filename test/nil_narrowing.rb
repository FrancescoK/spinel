# spinel: share
# A local is typed once for its whole life, so one nil written to it makes
# every read of it nullable: a compare tests for the sentinel, a box takes the
# nil-aware form, and the mark spreads to whatever the value is copied into.
# Nil narrowing proves single reads non-nil -- after a guard, after a non-nil
# write, under a flag set beside the variable's non-nil writes, and for an
# in-bounds index read of an array nothing can leave a nil or a hole in. Each
# shape below has a twin where the proof must NOT hold.
# spinel: decisions
def t
  yield
rescue => e
  e.class
end

# guards: nil?, ||, &&, unless, return-if, ||=
def best_of(xs)
  best = nil
  xs.each { |x| best = x if best.nil? || x > best }
  best
end
p best_of([3, 9, 2]), best_of([])

def guarded(h, k)
  v = h[k]
  return :none if v.nil?
  v + 1
end
p guarded({1 => 2}, 1), guarded({1 => 2}, 3)

def or_assigned(h)
  v = h[9]
  v ||= 7
  [v + 1, v > 5]
end
p or_assigned({})

def anded(h)
  v = h[2]
  v && v > 0
end
p anded({}), anded({2 => 3})

def unless_nil(h)
  v = h[1]
  r = unless v.nil? then v > 2 else :none end
  [r, t { v + 1 }]
end
p unless_nil({}), unless_nil({1 => 4})

# ... and where they do not hold: a closure, a block, a later nil
def closure_reset(xs)
  best = nil
  reset = -> { best = nil }
  out = []
  xs.each do |x|
    best = x if best.nil? || x > best
    reset.call if x == 3
    out << t { best + 1 }
  end
  out
end
p closure_reset([1, 3, 2])

def guard_then_proc
  x = 5
  set = proc { x = nil }
  if x
    set.call
    t { x + 1 }
  end
end
p guard_then_proc

def fiber_between
  x = 5
  out = []
  f = Fiber.new do
    if x
      Fiber.yield
      out << t { x + 1 }
    end
  end
  f.resume
  x = nil
  f.resume
  out
end
p fiber_between

def loop_nil_after_read
  x = 1
  i = 0
  out = []
  while i < 3
    out << t { x + 1 }
    x = nil if i == 1
    i += 1
  end
  out
end
p loop_nil_after_read

def retried
  tries = 0
  x = nil
  begin
    x = nil
    x = 4 if tries > 0
    tries += 1
    raise "again" if tries < 2
    t { x + 1 }
  rescue
    retry
  end
end
p retried

def and_assigned(h)
  v = h[1]
  v &&= 5
  t { v + 1 }
end
p and_assigned({})

# the flag set beside the first assignment
def lo_hi(xs)
  lo = nil
  hi = nil
  found = false
  xs.each do |x|
    if found
      lo = x if x < lo
      hi = x if x > hi
    else
      lo = x
      hi = x
      found = true
    end
  end
  [lo, hi]
end
p lo_hi([4, 1, 7]), lo_hi([])

# ... not when the nil is written without resetting the flag
def flag_broken(xs)
  lo = nil
  found = false
  pr = proc do |v|
    if found
      t { lo + v }
    else
      lo = v
      found = true
      :first
    end
  end
  a = pr.call(1)
  lo = nil
  [a, pr.call(2)]
end
p flag_broken([1])

# the builtins that keep their extremes behind such a flag
a = [3, 1, 2]
p a.minmax { |x, y| x <=> y }, a.max { |x, y| x <=> y }, a.inject { |s, x| s + x }
p a.min_by { |x| -x }, a.max_by { |x| -x }

# in-bounds reads of an array nothing leaves a nil or a hole in
class Rows
  def initialize(n) = (@rows = Array.new(n) { |i| i % 5 })
  def over(k)
    t = 0
    i = 0
    while i < @rows.size
      v = @rows[i]
      t += 1 if v > k
      i += 1
    end
    t
  end
  def each
    i = 0
    while i < @rows.size
      yield @rows[i]
      i += 1
    end
  end
end
r = Rows.new(10)
c = 0
r.each { |v| c += 1 if v > 2 }
p r.over(2), c

bins = [0, 1, 1, 3, 2, 1]
counts = Array.new(4, 0)
j = 0
while j < bins.length
  b = bins[j]
  counts[b] += 1
  j += 1
end
p counts

# ... and the arrays that can hold one: a write past the end leaves a gap
g = [1, 2]
g[3 + ARGV.size] = 4
i = 0
while i < g.size
  v = g[i]
  p [v, t { v > 0 }, {v => 1}]
  i += 1
end
gf = [1.5]
gf[2 + ARGV.size] = 2.5
i = 0
while i < gf.size
  v = gf[i]
  p [v, t { v > 0.0 }]
  i += 1
end

# a gap made through a method, a nil through an alias, insert, fill from a start
def grow(x, k) = (x[k] = 9)
h = [5, 6]
grow(h, 3 + ARGV.size)
i = 0
while i < h.size
  v = h[i]
  p t { v > 0 }
  i += 1
end
al = [1, 2]
al2 = al
al2 << {}[1]
i = 0
while i < al.size
  p t { al[i] > 0 }
  i += 1
end
ins = [1, 2]
ins.insert(3 + ARGV.size, 9)
i = 0
while i < ins.size
  p t { ins[i] > 0 }
  i += 1
end
fl = [1, 2, 3]
fl.fill(0, 4 + ARGV.size, 2)
i = 0
while i < fl.size
  p t { fl[i] > 0 }
  i += 1
end

# an attr_reader hands the array out
class Held
  attr_reader :rows
  def initialize = (@rows = [1, 2, 3])
  def over(k)
    n = 0
    i = 0
    while i < @rows.size
      n += 1 if @rows[i] > k
      i += 1
    end
    n
  end
end
hd = Held.new
hd.rows[5 + ARGV.size] = 9
p t { hd.over(0) }

# the index must start at zero or above
neg = [1, 2]
i = -5
while i < neg.size
  p t { neg[i] + 1 }
  i += 3
end

# the array shrinks inside the loop
sh = [1, 2, 3]
i = 0
while i < sh.size
  sh.pop if i == 1
  p t { sh[i] + 1 }
  i += 1
end
