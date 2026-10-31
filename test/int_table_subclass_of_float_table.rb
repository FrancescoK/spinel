# A subclass rewriting an ancestor's table with Integer rows: the ancestor's
# own methods (its initialize writes Float rows, `first` reads the slot) run
# on the subclass's copy too, so the subclass's copy stays the ancestor's
# layout. It was pinned to an Integer table on its own, and the build stopped
# on the two layouts ("type inference did not converge", then a class-layout
# refusal).
class Counts
  def initialize(n) = @t = Array.new(n) { |i| Array.new(n) { |j| i + j + 0.5 } }
  def first = @t[0][0]
  def last = @t[-1][-1]
end

class IntCounts < Counts
  def initialize(n)
    super(n)
    @t = Array.new(n) { |i| Array.new(n) { |j| i * j } }
  end
end

p Counts.new(2).first, IntCounts.new(3).first
p Counts.new(3).last, IntCounts.new(4).last

# Integer tables on both sides keep their narrowed layout.
class Grid
  def initialize(n) = @t = Array.new(n) { |i| Array.new(n) { |j| i + j } }
  def at(i, j) = @t[i][j]
end

class Scaled < Grid
  def initialize(n)
    super(n)
    @t = Array.new(n) { |i| Array.new(n) { |j| i * j } }
  end
end

s = 0
g = Scaled.new(30)
30.times { |i| 30.times { |j| s += g.at(i, j) } }
p s, Grid.new(2).at(1, 1)
