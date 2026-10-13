# An ivar assigned only an empty Array, filled through another name: the
# block the method yields it to, or a method it is passed to. Nothing in the
# ivar's own writes says what it holds, and the evidence-free default made it
# an Integer Array, so the String the block pushed raised TypeError.
class Gen
  def gen
    @src = []
    yield @src
    @src.join("\n")
  end

  def gen2
    @lines = []
    fill(@lines)
    @lines
  end

  def fill(a)
    a.push("x", "y")
  end
end

g = Gen.new
puts g.gen { |batch| batch << "def m" << "  1" << "end" }
p g.gen2
