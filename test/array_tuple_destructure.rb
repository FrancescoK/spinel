# An Array of pairs of Integers keeps its elements typed: `map` that
# returns a pair, `x, y = cells[i]` and `each { |x, y| }` give Integers
# (nil when the index or the pair is too short), not boxed values.

# `map` whose block returns a pair.
def map_range(n, i)
  cells = (0...n).map { |k| [k, k + 1] }
  cells[i][0] * 10 + cells[i][1]
end
p map_range(3, 2)

def map_array(i)
  cells = [4, 5, 6].map { |k| [k, k * k] }
  cells[i][0] * 100 + cells[i][1]
end
p map_array(1)

# `x, y = cells[i]` on a literal, on a `map` and on `<<`.
def from_literal(i)
  cells = [[1, 2], [3, 4]]
  x, y = cells[i]
  x * 10 + y
end
p from_literal(0), from_literal(1)

def from_map(n, i)
  cells = (0...n).map { |k| [k, k * 2] }
  x, y = cells[i]
  x * 10 + y
end
p from_map(4, 3)

def from_push(n, i)
  cells = []
  n.times { |k| cells << [k, k + 5] }
  x, y = cells[i]
  x * 10 + y
end
p from_push(3, 2)

# `each` and `map` with two block parameters.
def each_literal
  sum = 0
  [[1, 2], [3, 4]].each { |x, y| sum += x * y }
  sum
end
p each_literal

def each_map
  sum = 0
  (0...3).map { |k| [k, k * 2] }.each { |x, y| sum += x + y }
  sum
end
p each_map

def each_push
  sum = 0
  cells = []
  3.times { |k| cells << [k, k * 3] }
  cells.each { |x, y| sum += x * y }
  sum
end
p each_push

def map_pairs(n)
  (0...n).map { |k| [k, k + 2] }.map { |x, y| x * y }.sum
end
p map_pairs(4)

# Pairs of Floats.
def float_pairs(i)
  cells = (0...3).map { |k| [k * 0.5, k * 1.5] }
  x, y = cells[i]
  x + y
end
p float_pairs(2)

# The cells of the bodies near a point, as in a game: the bodies are of
# two classes, and each one is a pair of its cell coordinates.
class Cow
  attr_reader :x, :y
  def initialize(x, y) = (@x = x; @y = y)
end
class Hero
  attr_reader :x, :y
  def initialize(x, y) = (@x = x; @y = y)
end
def targets(cows, hero)
  (cows + [hero]).map { |body| [body.x.floor, body.y.floor] }
end
def strike_cell(cows, hero, pick)
  x = -1
  y = -1
  cells = targets(cows, hero)
  x, y = cells[pick % cells.size] unless cells.empty?
  x * 1000 + y
end
cows = [Cow.new(1.5, 2.5), Cow.new(3.5, 4.5)]
p strike_cell(cows, Hero.new(7.25, 8.75), 2), strike_cell(cows, Hero.new(0.5, 0.5), 4)
p strike_cell([], Hero.new(9.5, 9.5), 0)

# Out of range, short pairs and nil elements give nil, as in CRuby.
def miss(cells, i)
  x, y = cells[i]
  [x, y]
end
p miss((0...2).map { |k| [k, k] }, 5), miss([[1, 2]], -2)
p miss([[1], [2, 3]], 0), miss([[nil, 2], [3, 4]], 0)
def each_short
  out = []
  [[1], [2, 3]].each { |x, y| out << [x, y] }
  (0...2).map { |k| k.zero? ? [k] : [k, k] }.each { |x, y| out << [x, y] }
  out
end
p each_short
begin
  p from_literal(5)
rescue NoMethodError => e
  p e.class
end

# A pair of an Integer and a String stays as it is.
def mixed_pairs
  (0...2).map { |k| [k, k.to_s] }.map { |n, s| s * (n + 1) }
end
p mixed_pairs

# Float rows, a nil row, a walk whose value is used, a map with next or
# break, a third parameter past the row and a parameter given another value.
def float_literal
  sum = 0.0
  [[1.5, 2.5], [3.0, 4.0]].each { |x, y| sum += x * y }
  sum
end
p float_literal
def float_map_each
  out = []
  (0...3).map { |k| [k * 0.5, k * 1.5] }.each { |x, y| out << x + y }
  out
end
p float_map_each
def nil_row
  cells = []
  cells << [1, 2]
  cells << nil
  out = []
  cells.each { |x, y| out << [x, y] }
  a, b = cells[1]
  out << [a, b]
  out
end
p nil_row
def each_value_used
  [[1, 2], [3, 4]].each { |a, b| a + b }
end
p each_value_used
def map_next(n)
  (0...n).map { |k| next [0, 0] if k == 1; [k, k] }.map { |x, y| x + y }
end
p map_next(3)
def map_break(n)
  cells = (0...n).map { |k| break [9, 8] if k == 1; [k, k] }
  x, y = cells[0]
  [x, y, cells.size]
end
p map_break(3), map_break(1)
def three_params
  out = []
  (0...2).map { |k| [k, k + 1] }.each { |x, y, z| out << [x, y, z] }
  out
end
p three_params
def param_rebound
  out = []
  cells = []
  2.times { |k| cells << [k, k] }
  cells.each { |x, y| x = "s#{x}"; out << x << y }
  out
end
p param_rebound
