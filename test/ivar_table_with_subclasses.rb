# An ivar table narrows in a class that has subclasses
# A subclass's copy of an ancestor's ivar is the ancestor's: its struct begins
# with the same fields and inherited methods read them through a cast, so the
# table narrows when the subclasses' uses are vetted too, and every copy takes
# the one type. A subclass that writes rows of another kind, hands the table
# to a dynamic call through its own reader, or has a writer called keeps it
# boxed, in the class and every subclass alike.

class Grid
  def initialize(n)
    @t = Array.new(n) { |i| Array.new(n) { |j| (i * j) * 0.5 } }
  end

  def total
    s = 0.0
    @t.each { |row| row.each { |x| s += x } }
    s
  end
end

class Scaled < Grid
  def initialize(n, k)
    super(n)
    @k = k
  end

  def scaled = total * @k
  def corner = @t[1][1] + @t[0][0]
end

class Deep < Scaled
  def initialize(n) = super(n, 3)
  def row_sum(i) = @t[i].sum
end

# a subclass writes rows that hold a String: the table stays boxed
class Counts
  def initialize(n) = @t = Array.new(n) { |i| Array.new(n) { |j| i + j + 0.5 } }
  def first = @t[0][0]
end

class Labeled < Counts
  def initialize(n)
    super(n)
    @t = Array.new(n) { |i| [i * 1.5, "row #{i}"] }
  end
end

# a subclass's own reader, reached by a dynamic call
class Shared
  def initialize(n) = @t = Array.new(n) { |i| Array.new(n) { |j| i - j + 0.25 } }
  def width = @t.size
end

class Exposed < Shared
  attr_reader :t
end

# a writer of a subclass, called
class Store
  def initialize(n) = @t = Array.new(n) { |i| Array.new(n) { |j| j * 1.5 } }
  def total = @t.sum { |row| row.sum }
end

class OpenStore < Store
  attr_writer :t
end

g = Grid.new(3)
s = Scaled.new(3, 2)
d = Deep.new(4)
p g.total, s.scaled, s.corner, d.scaled, d.row_sum(3), d.total
p Counts.new(2).first, Labeled.new(3).first
x = [Exposed.new(2), "s"][ARGV.size]
p x.t, x.width
o = OpenStore.new(2)
p o.total
o.t = [[1.0, 2.0], [3.0]]
p o.total
p [g, s, d].map(&:total)
