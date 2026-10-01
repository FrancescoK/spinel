# Reads proven non-nil compare without the sentinel test (nil narrowing):
# after a guard, under a flag set beside the first assignment, and for an
# in-bounds read of an array nothing can leave a nil or a hole in. A
# variable that stays nilable keeps the other operand's half of the test.

def best_of(xs)
  best = nil
  xs.each { |x| best = x if best.nil? || x > best }
  best
end

def guarded(h, k)
  w = h[k]
  return 0 if w.nil?
  w > 2 ? 1 : 2
end

def lo_of(xs)
  lo = nil
  found = false
  xs.each do |x|
    if found
      lo = x if x < lo
    else
      lo = x
      found = true
    end
  end
  lo
end

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
end

g = [1, 2]
g[3 + ARGV.size] = 4
gc = 0
begin
  gi = 0
  while gi < g.size
    gv = g[gi]
    gc += 1 if gv > 0
    gi += 1
  end
rescue NoMethodError
  gc = -1
end

p best_of([1, 2]), guarded({1 => 3}, 1), lo_of([2, 1]), Rows.new(4).over(1), gc
