# `a + b` with arrays of different kinds builds a Poly array from two
# temporaries. Neither temporary was a GC root, so a collection while the
# right operand was built swept the left one (a fresh concatenation) and
# the result read freed memory. Covers a typed left with a Poly right, a
# Poly left with a typed right, and an Integer array beside a String one.
def collecting_poly(n)
  GC.start
  junk = []
  n.times { |i| junk << ("#" * 40 + i.to_s) }
  [junk.first, n]
end

def collecting_strs
  GC.start
  junk = []
  2000.times { |i| junk << ("%" * 40 + i.to_s) }
  [junk.last]
end

lines = %w[name author].reject(&:empty?) + ["at #{ARGV.size} Hz"] + collecting_poly(2000)
p lines

mixed = [1, "x"].reject(&:nil?) + (%w[p q].map(&:upcase) + collecting_strs)
p mixed

nums = [1, 2, 3].select(&:odd?) + collecting_strs
p nums
