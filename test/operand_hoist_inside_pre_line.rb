# An operand that hoists statements of its own (a call through a method
# with a default argument, a value stored through a setter and read back)
# in a place the emitter writes into the statement prelude part way
# through a line: a multi-value yield's packed array, an Enumerator's
# values. The hoisted statements went into the middle of that line and the
# C did not build.
def w(v, d = nil) = v
class Cell
  def set(v) = (@v = v; self)
  def get = @v
end
e = Enumerator.new { |y| y.yield(1, w(2), 3); y << 9 }
p e.to_a
e2 = Enumerator.new { |y| y.yield(Cell.new.set(4).get, 5) }
p e2.next
p [10, 20].each_slice(w(1)).to_a
p (1..w(4)).step(w(2)).to_a
