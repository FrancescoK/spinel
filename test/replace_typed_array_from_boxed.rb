# Array#replace on a typed array that reaches the call untyped takes the
# elements of an array of another kind, as CRuby does.

Point = Struct.new(:x)

def refill(array, source) = array.replace(source)
def pick(array) = ARGV.empty? ? array : "not an array"

ints = [0, 0, 0]
refill(pick(ints), [1, nil, "x"].first(1) + [2, 3])
p ints

holes = [5, 5]
refill(pick(holes), [nil, :a].first(1) + [7])
p holes

words = ["old"]
refill(pick(words), ["new", 1].first(1) + ["list"])
p words

points = [Point.new(0)]
refill(pick(points), [Point.new(1), 2].first(1) + [Point.new(3)])
p points.map(&:x)

shrink = [9, 9, 9, 9]
refill(pick(shrink), [4, :b].first(1))
p shrink

frozen = [1, 2].freeze
begin
  refill(pick(frozen), [3, :c].first(1))
rescue FrozenError => e
  puts e.class
end
p frozen
