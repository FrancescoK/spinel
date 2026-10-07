# A store into a box that can hold no Struct reaches no Struct's `[]=`, so
# it types no member: the member keeps the String it was built with, and
# the String's in-place change reads back through it (a member typed for
# a value that never reaches it holds a copy). So does a box whose classes
# the analysis cannot tell (a method's answer, an ivar): its store checks
# the value where it runs instead.
S = Struct.new(:x)
s = +"abc"
o = S.new(s)
s << "d"
p o.x
o.x << "e"
p s
q = [{x: 1}, 2][0]
q[:x] = 4
k = [:x, :y][ARGV.size]
q[k] = 4.5
p q

def pick(i) = [[1, 2], {0 => 1}][i]
r = pick(ARGV.size)
r[0] = 5
p r

class Box
  def initialize(v); @v = v; end
  def set(k, val); @v[k] = val; self; end
  def v = @v
end
p Box.new({a: 1}).set(:a, 2).v
p Box.new([1]).set(0, 2).v
p o.x
