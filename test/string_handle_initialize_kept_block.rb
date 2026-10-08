# A block `new` hands to an initialize that keeps it as `&b` shares the
# caller's String when it is called later with one. A kept block was found
# by the call's name, and no method is named `new`: the block's parameter
# kept the value ABI, the program counted no target that appends, and
# `@b.call(s)` appended to a copy without a word, where the same block kept
# by an ordinary method shared it (#6179). Each probe appends LONG, which
# always reallocates, and prints what the caller's name sees.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]

class Agg
  def initialize(&b) = (@b = b)
  def run(s) = (@b.call(s); s.size)
end
class Sub < Agg; end
class Chi < Agg
  def initialize(&b) = super
end
s = +"A"; p Agg.new { |t| t << LONG }.run(s), seen(s)
s = +"B"; p Sub.new { |t| t.concat(LONG) }.run(s), seen(s)
s = +"C"; p Chi.new { |t| t << LONG }.run(s), seen(s)

# kept and also called in the initialize, a later position, a keyword
# beside the block, and a block that only reads
class Both
  def initialize(s, &b) = (@b = b; b.call(s))
  def again(s) = @b.call(s)
end
class Two
  def initialize(k: 1, &b) = (@b = b; @k = k)
  def run(s) = @b.call(@k, s)
end
s = +"D"; o = Both.new(s) { |t| t << LONG }; p seen(s); o.again(s); p seen(s)
s = +"E"; Two.new(k: 2) { |x, t| t << LONG * x }.run(s); p seen(s)
s = +"F"; p Agg.new { |t| t.size }.run(s), seen(s)

# kept blocks called after the objects that hold them were made, while the
# collector runs
objs = (0..5).map { |i| Agg.new { |t| t << "#{i}" * 40 } }
bufs = []
i = 0
while i < 6
  b = +"k"
  objs[i].run(b)
  bufs << b
  junk = Array.new(40) { |j| "j#{j}" * 20 }
  i += 1
end
p bufs.map(&:size), bufs[3][0, 3]
