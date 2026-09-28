# A symbol proc over a boxed generator calls the method with the second value
# only for a step that yielded several; a one-value step keeps the default.
class O
  def probe(x = :default) = x
end
o = O.new
g = Enumerator.new { |y| y.yield(o, 7); y.yield(o) }
p [g, 1][0].map(&:probe)
p g.map(&:probe)
g2 = Enumerator.new { |y| y.yield(10, 2); y.yield([7, 8]); y << 16 }
p [g2, 1][0].map(&:to_s)
