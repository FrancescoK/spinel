# A local whose plain writes all read one element type out of an array is
# narrowed to that type, but only when its other writes store that type too:
# a `||=` or `&&=` of another kind, an op-assign whose operator answers
# another kind, or a multiple-assignment target keeps it boxed.

class P
  attr_reader :v
  def initialize(v) = (@v = v)
end
rows = [P.new(1), P.new(2)]

a = rows[ARGV.size + 5]
a ||= "s"
p a
b = rows[ARGV.size]
b, = ["t"] if ARGV.empty?
p b
c = rows[ARGV.size + 1]
p c.v

f = [1.5, [1.5][ARGV.size + 1]][1]
f ||= 7
p f
g = [2.5][ARGV.size]
g &&= 3
p g
h = [1.5][ARGV.size]
h += 1
p h
i = [1, 2][ARGV.size + 5]
i ||= 7.5
p i
j = [3, 4][ARGV.size]
j += 0.5
p j
k = ["x", "y"][ARGV.size]
k += "z"
p k
